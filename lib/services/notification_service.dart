// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'notification_preferences_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static bool _isInitialized = false;
  static final DatabaseReference _alertsRef =
      FirebaseDatabase.instance.ref().child('devices').child('esp32_001').child('alerts');
  
  static DateTime _appStartTime = DateTime.now();

  // Initialize notification
  static Future<void> initialize() async {
    if (_isInitialized) {
      print('🔔 Notification already initialized');
      return;
    }

    // Initialize preferences
    await NotificationPreferencesService.initialize();

    _appStartTime = DateTime.now();
    print('🔔 App start time: $_appStartTime');

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    
    final initialized = await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        print('🔔 Notification tapped: ${details.payload}');
      },
    );
    
    print('🔔 Notification initialized: $initialized');
    _isInitialized = true;

    // Listen untuk alert baru dari Firebase
    _listenForAlerts();
  }

  // Check if user is logged in
  static bool _isUserLoggedIn() {
    final user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  // Listen untuk alert dari Firebase - REALTIME!
  static void _listenForAlerts() {
    print('🔔 Starting to listen for Firebase alerts...');
    
    _alertsRef.onChildAdded.listen((event) async {
      // CEK APAKAH USER SUDAH LOGIN
      if (!_isUserLoggedIn()) {
        print('🔔 ⏭️ User not logged in, skipping notification');
        return;
      }
      
      if (event.snapshot.value != null) {
        final alertData = Map<String, dynamic>.from(event.snapshot.value as Map);
        final detectedAt = alertData['detected_at'] ?? 0;
        final mq2Value = alertData['mq2_value'] ?? 0;
        final severity = alertData['severity'] ?? 'warning';
        
        // Convert timestamp ke DateTime
        final alertTime = DateTime.fromMillisecondsSinceEpoch(detectedAt * 1000);
        
        print('🔔 Alert detected: time=$alertTime, app_start=$_appStartTime');
        print('🔔 Severity: $severity, MQ2: $mq2Value');
        
        // Kirim notif jika alert lebih baru dari waktu app start (toleransi 5 detik)
        final timeDiff = alertTime.difference(_appStartTime).inSeconds;
        print('🔔 Time difference: $timeDiff seconds');
        
        if (timeDiff >= -5) {  // Toleransi 5 detik
          // Check user preference for this severity
          // Hanya kirim notifikasi untuk 'high' dan 'critical'
          final shouldNotify = await NotificationPreferencesService.shouldSendNotification(severity);
          
          if (!shouldNotify) {
            print('🔔 ⏭️ Notification for $severity is disabled or not supported, skipping...');
            return;
          }
          
          print('🔔 ✅ NEW ALERT! Sending notification...');
          
          String title;
          Color notifColor;
          
          if (severity == 'critical') {
            title = '🚨 BAHAYA! KEBOCORAN GAS KRITIS';
            notifColor = const Color(0xFFFF0000);  // Red
          } else if (severity == 'high') {
            title = '⚠️ PERINGATAN! KEBOCORAN GAS TINGGI';
            notifColor = const Color(0xFFFF6600);  // Orange
          } else {
            // Skip warning dan severity lainnya
            print('🔔 ⏭️ Severity $severity not supported for notifications');
            return;
          }
          
          final body = 'Terdeteksi gas berbahaya!\nNilai: $mq2Value PPM\nTingkat: ${severity.toUpperCase()}';
          
          // Kirim local notification
          await _showAlertNotification(
            title: title,
            body: body,
            severity: severity,
            color: notifColor,
          );
        } else {
          print('🔔 ❌ Old alert ($timeDiff seconds), skipping notification');
        }
      }
    }, onError: (error) {
      print('🔔 Error listening to alerts: $error');
    });
  }

  // Show notification
  static Future<void> _showAlertNotification({
    required String title,
    required String body,
    required String severity,
    required Color color,
  }) async {
    print('🔔 📢 Showing notification: $title');
    print('🔔 📢 Body: $body');
    
    final androidDetails = AndroidNotificationDetails(
      'gas_alert_channel',
      'Gas Alert',
      channelDescription: 'Notifikasi untuk alert kebocoran gas berbahaya',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Gas Alert',
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      enableLights: true,
      color: color,
      ledColor: color,
      ledOnMs: 1000,
      ledOffMs: 500,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: 'Asrama Safe',
      ),
      category: AndroidNotificationCategory.alarm,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    try {
      final notificationId = DateTime.now().millisecondsSinceEpoch % 100000;
      
      await _notifications.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: severity,
      );
      
      print('🔔 ✅ Notification sent successfully! ID: $notificationId');
    } catch (e) {
      print('🔔 ❌ Error showing notification: $e');
    }
  }

  // Request permission (Android 13+)
  static Future<bool> requestPermission() async {
    print('🔔 Requesting notification permission...');
    
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      print('🔔 Permission granted: $granted');
      return granted ?? false;
    }
    
    print('🔔 Android plugin not found');
    return false;
  }

  // Manual test notification
  static Future<void> testNotification() async {
    print('🔔 Testing manual notification...');
    await _showAlertNotification(
      title: '🔔 TEST NOTIFICATION',
      body: 'Ini adalah test notification dari Asrama Safe\nNilai: 999 PPM\nTingkat: TEST',
      severity: 'test',
      color: const Color(0xFF0000FF),
    );
  }
}
