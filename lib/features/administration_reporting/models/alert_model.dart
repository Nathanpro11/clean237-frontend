import 'package:intl/intl.dart';

enum AlertSeverity { critical, warning, info }

enum AlertStatus { active, treated }

class AdminAlert {
  const AdminAlert({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.zoneId,
    required this.zoneName,
    required this.dateTime,
    required this.severity,
    required this.status,
    this.context,
    this.impact,
  });

  final String id;
  final String title;
  final String subtitle;
  final String zoneId;
  final String zoneName;
  final DateTime dateTime;
  final String? context;
  final String? impact;
  final AlertSeverity severity;
  final AlertStatus status;

  String get date => DateFormat('dd/MM/yyyy HH:mm').format(dateTime.toLocal());
  bool get isHandled => status == AlertStatus.treated;

  AdminAlert copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? zoneId,
    String? zoneName,
    DateTime? dateTime,
    String? context,
    String? impact,
    AlertSeverity? severity,
    AlertStatus? status,
  }) => AdminAlert(
    id: id ?? this.id,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    zoneId: zoneId ?? this.zoneId,
    zoneName: zoneName ?? this.zoneName,
    dateTime: dateTime ?? this.dateTime,
    context: context ?? this.context,
    impact: impact ?? this.impact,
    severity: severity ?? this.severity,
    status: status ?? this.status,
  );
}
