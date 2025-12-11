// lib/models/alert_model.dart
class GasAlert {
  final String id;
  final int mq2Value;
  final String severity;
  final DateTime detectedAt;
  final bool acknowledged;

  GasAlert({
    required this.id,
    required this.mq2Value,
    required this.severity,
    required this.detectedAt,
    required this.acknowledged,
  });

  factory GasAlert.fromMap(String id, Map<dynamic, dynamic> map) {
    return GasAlert(
      id: id,
      mq2Value: (map['mq2_value'] ?? 0) as int,
      severity: (map['severity'] ?? 'low') as String,
      detectedAt: DateTime.fromMillisecondsSinceEpoch(
        ((map['detected_at'] ?? 0) as int) * 1000,
      ),
      acknowledged: (map['acknowledged'] ?? false) as bool,
    );
  }

  String get severityIcon {
    switch (severity) {
      case 'critical':
        return '🔴';
      case 'high':
        return '🟠';
      default:
        return '🟡';
    }
  }
}
