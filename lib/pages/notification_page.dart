// lib/pages/notification_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final DatabaseReference _alertsRef = 
      FirebaseDatabase.instance.ref().child('devices').child('esp32_001').child('alerts');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _alertsRef.orderByChild('detected_at').onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada notifikasi',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          final snapshotValue = snapshot.data!.snapshot.value;
          
          if (snapshotValue is! Map) {
            return Center(
              child: Text(
                'Format data tidak valid',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          // ← FIX: Hapus 'as Map' yang unnecessary
          final alertsMap = Map<String, dynamic>.from(snapshotValue);
          final alertsList = <Map<String, dynamic>>[];

          alertsMap.forEach((key, value) {
            if (value is Map) {
              // ← FIX: Hapus 'as Map' yang unnecessary
              final alertData = Map<String, dynamic>.from(value);
              alertData['key'] = key;
              alertsList.add(alertData);
            }
          });

          if (alertsList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada notifikasi',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          // Sort by timestamp descending (terbaru di atas)
          alertsList.sort((a, b) {
            final timeA = a['detected_at'] ?? 0;
            final timeB = b['detected_at'] ?? 0;
            return timeB.compareTo(timeA);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: alertsList.length,
            itemBuilder: (context, index) {
              final alert = alertsList[index];
              
              final mq2Value = alert['mq2_value'] ?? 0;
              final severity = alert['severity'] ?? 'warning';
              final detectedAt = alert['detected_at'];
              final acknowledged = alert['acknowledged'] == true;

              // Calculate time ago
              String timeAgo = 'Baru saja';
              if (detectedAt != null && detectedAt is int) {
                final dateTime = DateTime.fromMillisecondsSinceEpoch(detectedAt * 1000);
                final difference = DateTime.now().difference(dateTime);
                
                if (difference.inMinutes < 1) {
                  timeAgo = 'Baru saja';
                } else if (difference.inMinutes < 60) {
                  timeAgo = '${difference.inMinutes} menit yang lalu';
                } else if (difference.inHours < 24) {
                  timeAgo = '${difference.inHours} jam yang lalu';
                } else {
                  timeAgo = DateFormat('dd MMM HH:mm').format(dateTime);
                }
              }

              // Determine color and title based on severity
              Color alertColor;
              String title;
              IconData icon;
              
              if (severity == 'critical') {
                alertColor = kWarningRed;
                title = 'BAHAYA! Kebocoran Gas Kritis';
                icon = Icons.dangerous;
              } else if (severity == 'high') {
                alertColor = Colors.orange;
                title = 'PERINGATAN! Kebocoran Gas Tinggi';
                icon = Icons.warning;
              } else {
                alertColor = kWarningYellow;
                title = 'Deteksi Gas Meningkat';
                icon = Icons.warning_amber;
              }

              return _buildNotificationItem(
                title: title,
                subtitle: 'Nilai MQ2: $mq2Value PPM',
                color: alertColor,
                icon: icon,
                timestamp: timeAgo,
                acknowledged: acknowledged,
                onTap: () {
                  _acknowledgeAlert(alert['key']);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required String timestamp,
    required bool acknowledged,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: acknowledged ? Colors.grey[100] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: acknowledged ? Colors.grey[300]! : color.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: acknowledged 
                  ? Colors.black.withOpacity(0.05)
                  : color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(
                acknowledged ? Icons.check_circle : icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: acknowledged ? Colors.grey[600] : color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timestamp,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (!acknowledged)
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _acknowledgeAlert(String alertKey) async {
    try {
      await _alertsRef.child(alertKey).update({
        'acknowledged': true,
        'acknowledged_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifikasi ditandai sebagai dibaca'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menandai notifikasi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
