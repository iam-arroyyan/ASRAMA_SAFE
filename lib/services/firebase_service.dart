// lib/services/firebase_service.dart
import 'package:firebase_database/firebase_database.dart';
import '../models/gas_reading.dart';
import '../models/alert_model.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final String deviceId;

  FirebaseService({this.deviceId = 'esp32_001'});

  Stream<GasReading?> get latestReadingStream {
    return _db.child('readings').child(deviceId).onValue.map((event) {
      if (!event.snapshot.exists) return null;

      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final dates = data.keys.map((e) => e.toString()).toList()..sort();
      if (dates.isEmpty) return null;
      final lastDate = dates.last;

      final dateData = data[lastDate] as Map<dynamic, dynamic>;
      final times = dateData.keys.map((e) => e.toString()).toList()..sort();
      if (times.isEmpty) return null;
      final lastTime = times.last;

      final readingData = dateData[lastTime] as Map<dynamic, dynamic>;
      return GasReading.fromMap(readingData);
    });
  }

  Stream<List<GasAlert>> get alertsStream {
    return _db.child('alerts').child(deviceId).onValue.map((event) {
      if (!event.snapshot.exists) return <GasAlert>[];

      final data = event.snapshot.value;
      if (data is! Map) return <GasAlert>[];

      final alerts = <GasAlert>[];

      data.forEach((key, value) {
        if (value != null && value is Map) {
          alerts.add(GasAlert.fromMap(
            key.toString(),
            Map<String, dynamic>.from(value),  // ← FIX: Tanpa cast
          ));
        }
      });

      alerts.sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
      return alerts;
    });
  }

  Future<void> acknowledgeAlert(String alertId) async {
    await _db.child('alerts').child(deviceId).child(alertId).update({
      'acknowledged': true,
      'acknowledged_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    });
  }
}
