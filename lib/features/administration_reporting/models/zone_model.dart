import 'package:intl/intl.dart';

enum ZoneStatus { normal, warning, critical }

extension ZoneStatusExtension on ZoneStatus {
  String get label {
    switch (this) {
      case ZoneStatus.normal:
        return 'Normal';
      case ZoneStatus.warning:
        return 'À surveiller';
      case ZoneStatus.critical:
        return 'Critique';
    }
  }
}

class Zone {
  const Zone({
    required this.id,
    required this.name,
    required this.score,
    required this.status,
    this.severityScore,
    this.evolutionPoints,
    this.lastUpdatedAt,
    this.alertCount,
    this.dataCount,
    this.evolution30Days = const [],
    this.interpretation,
    this.priorities = const [],
  });

  final String id;
  final String name;
  final int score;
  final ZoneStatus status;
  final int? severityScore;
  final int? evolutionPoints;
  final DateTime? lastUpdatedAt;
  final int? alertCount;
  final int? dataCount;
  final List<double> evolution30Days;
  final String? interpretation;
  final List<String> priorities;

  String get lastUpdate => lastUpdatedAt == null
      ? ''
      : DateFormat('d MMM, HH:mm', 'fr').format(lastUpdatedAt!.toLocal());

  Zone copyWith({
    String? id,
    String? name,
    int? score,
    ZoneStatus? status,
    int? severityScore,
    int? evolutionPoints,
    DateTime? lastUpdatedAt,
    int? alertCount,
    int? dataCount,
    List<double>? evolution30Days,
    String? interpretation,
    List<String>? priorities,
  }) => Zone(
    id: id ?? this.id,
    name: name ?? this.name,
    score: score ?? this.score,
    status: status ?? this.status,
    severityScore: severityScore ?? this.severityScore,
    evolutionPoints: evolutionPoints ?? this.evolutionPoints,
    lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    alertCount: alertCount ?? this.alertCount,
    dataCount: dataCount ?? this.dataCount,
    evolution30Days: evolution30Days ?? this.evolution30Days,
    interpretation: interpretation ?? this.interpretation,
    priorities: priorities ?? this.priorities,
  );
}
