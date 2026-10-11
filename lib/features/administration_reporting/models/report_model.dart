enum ReportType { synthesis, tracking, export }

extension ReportTypeExtension on ReportType {
  String get label {
    switch (this) {
      case ReportType.synthesis:
        return 'Synthèse';
      case ReportType.tracking:
        return 'Suivi';
      case ReportType.export:
        return 'Export';
    }
  }
}

enum ReportStatus { ready, inProgress, archived }

extension ReportStatusExtension on ReportStatus {
  String get label {
    switch (this) {
      case ReportStatus.ready:
        return 'Prêt';
      case ReportStatus.inProgress:
        return 'En cours';
      case ReportStatus.archived:
        return 'Archivé';
    }
  }
}

class AdminReport {
  final String id;
  final String title;
  final ReportType type;
  final ReportStatus status;
  final String date;
  final int zoneCount;
  final List<String> zoneNames;
  final String summary;

  const AdminReport({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.date,
    required this.zoneCount,
    this.zoneNames = const [],
    this.summary = '',
  });

  AdminReport copyWith({
    String? id,
    String? title,
    ReportType? type,
    ReportStatus? status,
    String? date,
    int? zoneCount,
    List<String>? zoneNames,
    String? summary,
  }) {
    return AdminReport(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      date: date ?? this.date,
      zoneCount: zoneCount ?? this.zoneCount,
      zoneNames: zoneNames ?? this.zoneNames,
      summary: summary ?? this.summary,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'status': status.name,
      'date': date,
      'zoneCount': zoneCount,
      'zoneNames': zoneNames,
      'summary': summary,
    };
  }

  factory AdminReport.fromMap(Map<String, dynamic> map) {
    return AdminReport(
      id: map['id'] as String,
      title: map['title'] as String,
      type: ReportType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ReportType.synthesis,
      ),
      status: ReportStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReportStatus.ready,
      ),
      date: map['date'] as String,
      zoneCount: (map['zoneCount'] as num).toInt(),
      zoneNames: (map['zoneNames'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      summary: map['summary'] as String? ?? '',
    );
  }
}
