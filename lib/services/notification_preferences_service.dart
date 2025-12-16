// lib/services/notification_preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferencesService {
  static const String _keyGasHigh = 'notif_gas_high';
  static const String _keyGasCritical = 'notif_gas_critical';

  static SharedPreferences? _prefs;

  // Initialize shared preferences
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Get preferences instance
  static Future<SharedPreferences> _getPrefs() async {
    if (_prefs == null) {
      await initialize();
    }
    return _prefs!;
  }

  // Gas High notification (severity: high)
  static Future<bool> getGasHighEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_keyGasHigh) ?? true;
  }

  static Future<void> setGasHighEnabled(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyGasHigh, value);
  }

  // Gas Critical notification (severity: critical)
  static Future<bool> getGasCriticalEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_keyGasCritical) ?? true;
  }

  static Future<void> setGasCriticalEnabled(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyGasCritical, value);
  }

  // Check if notification should be sent based on severity
  static Future<bool> shouldSendNotification(String severity) async {
    switch (severity) {
      case 'high':
        return await getGasHighEnabled();
      case 'critical':
        return await getGasCriticalEnabled();
      default:
        // Untuk severity 'warning' atau lainnya, tidak kirim notifikasi
        return false;
    }
  }
}
