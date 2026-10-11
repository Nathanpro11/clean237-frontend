enum AlertSeverity { critical, warning, info }

class AdminAlert {
  final String id;
  final String title;
  final String subtitle;
  final String zoneId;
  final String zoneName;
  final String date;
  final String context;
  final String impact;
  final AlertSeverity severity;
  final bool isHandled;

  const AdminAlert({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.zoneId,
    required this.zoneName,
    required this.date,
    required this.context,
    required this.impact,
    this.severity = AlertSeverity.critical,
    this.isHandled = false,
  });

  AdminAlert copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? zoneId,
    String? zoneName,
    String? date,
    String? context,
    String? impact,
    AlertSeverity? severity,
    bool? isHandled,
  }) {
    return AdminAlert(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
      date: date ?? this.date,
      context: context ?? this.context,
      impact: impact ?? this.impact,
      severity: severity ?? this.severity,
      isHandled: isHandled ?? this.isHandled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'zoneId': zoneId,
      'zoneName': zoneName,
      'date': date,
      'context': context,
      'impact': impact,
      'severity': severity.name,
      'isHandled': isHandled,
    };
  }

  factory AdminAlert.fromMap(Map<String, dynamic> map) {
    return AdminAlert(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      zoneId: map['zoneId'] as String,
      zoneName: map['zoneName'] as String,
      date: map['date'] as String,
      context: map['context'] as String,
      impact: map['impact'] as String,
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == map['severity'],
        orElse: () => AlertSeverity.critical,
      ),
      isHandled: map['isHandled'] as bool? ?? false,
    );
  }
}
