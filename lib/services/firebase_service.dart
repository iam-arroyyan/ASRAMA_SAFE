// lib/services/firebase_service.dart
import 'package:firebase_database/firebase_database.dart';
import '../models/gas_reading.dart';
import '../models/alert_model.dart';

class FirebaseService {
  final String deviceId;
  late final DatabaseReference _deviceRef;

  FirebaseService({this.deviceId = 'esp32_001'}) {
    // Path baru: /devices/esp32_001/
    _deviceRef = FirebaseDatabase.instance.ref().child('devices').child(deviceId);
  }

  // Stream untuk status realtime (dari /devices/{id}/status)
  Stream<GasReading?> get latestReadingStream {
    return _deviceRef.child('status').onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return null;
      }

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return GasReading.fromMap(data);
    });
  }

  // Stream untuk history readings (dari /devices/{id}/readings)
  // Limit 500 untuk mencakup data beberapa jam (untuk chart per jam)
  Stream<List<GasReading>> get readingsHistoryStream {
    return _deviceRef.child('readings').orderByChild('timestamp').limitToLast(500).onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return <GasReading>[];
      }

      final data = event.snapshot.value;
      if (data is! Map) return <GasReading>[];

      final readings = <GasReading>[];
      data.forEach((key, value) {
        if (value is Map) {
          readings.add(GasReading.fromMap(Map<String, dynamic>.from(value)));
        }
      });

      readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return readings;
    });
  }

  // Stream untuk alerts (dari /devices/{id}/alerts)
  Stream<List<GasAlert>> get alertsStream {
    return _deviceRef.child('alerts').onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return <GasAlert>[];
      }

      final data = event.snapshot.value;
      if (data is! Map) return <GasAlert>[];

      final alerts = <GasAlert>[];

      data.forEach((key, value) {
        if (value != null && value is Map) {
          alerts.add(GasAlert.fromMap(
            key.toString(),
            Map<String, dynamic>.from(value),
          ));
        }
      });

      alerts.sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
      return alerts;
    });
  }

  // Acknowledge alert
  Future<void> acknowledgeAlert(String alertId) async {
    await _deviceRef.child('alerts').child(alertId).update({
      'acknowledged': true,
      'acknowledged_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    });
  }

  // Get device info
  Future<Map<String, dynamic>?> getDeviceInfo() async {
    final snapshot = await _deviceRef.child('info').get();
    if (snapshot.exists && snapshot.value != null) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null;
  }
}
