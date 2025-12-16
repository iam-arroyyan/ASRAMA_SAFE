// lib/models/gas_reading.dart
class GasReading {
  final int mq2Raw;
  final int threshold;
  final int baseline;
  final bool isAlert;
  final DateTime timestamp;
  final double ppm;

  GasReading({
    required this.mq2Raw,
    required this.threshold,
    required this.baseline,
    required this.isAlert,
    required this.timestamp,
    required this.ppm,
  });

  factory GasReading.fromMap(Map<dynamic, dynamic> map) {
    // Support both 'timestamp' (history) and 'last_update' (status) fields
    final timestampValue = map['timestamp'] ?? map['last_update'] ?? 0;
    
    return GasReading(
      mq2Raw: (map['mq2_raw'] ?? 0) as int,
      threshold: (map['threshold'] ?? 0) as int,
      baseline: (map['baseline'] ?? 0) as int,
      isAlert: (map['is_alert'] ?? false) as bool,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (timestampValue as int) * 1000,
      ),
      ppm: ((map['ppm'] ?? 0) as num).toDouble(),
    );
  }

  bool get isSafe => !isAlert;
  String get statusText => isAlert ? 'BAHAYA' : 'AMAN';
}
