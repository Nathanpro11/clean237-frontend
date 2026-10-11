import 'analysis_model.dart';

enum ReportType { synthesis, tracking, export }

enum ReportFormat { pdf, excel, csv }

extension ReportFormatExtension on ReportFormat {
  String get label => switch (this) {
    ReportFormat.pdf => 'PDF (.pdf)',
    ReportFormat.excel => 'Excel (.xlsx)',
    ReportFormat.csv => 'CSV (.csv)',
  };
}

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
  final String analysisId;
  final String description;
  final ReportFormat format;
  final DateTime createdAt;
  final AnalysisIndicators indicators;

  const AdminReport({
    required this.id,
    required this.analysisId,
    required this.title,
    required this.type,
    required this.status,
    required this.date,
    required this.zoneCount,
    required this.createdAt,
    required this.indicators,
    this.zoneNames = const [],
    this.summary = '',
    this.description = '',
    this.format = ReportFormat.pdf,
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
    String? analysisId,
    String? description,
    ReportFormat? format,
    DateTime? createdAt,
    AnalysisIndicators? indicators,
  }) {
    return AdminReport(
      id: id ?? this.id,
      analysisId: analysisId ?? this.analysisId,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      date: date ?? this.date,
      zoneCount: zoneCount ?? this.zoneCount,
      zoneNames: zoneNames ?? this.zoneNames,
      summary: summary ?? this.summary,
      description: description ?? this.description,
      format: format ?? this.format,
      createdAt: createdAt ?? this.createdAt,
      indicators: indicators ?? this.indicators,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'analysisId': analysisId,
      'title': title,
      'type': type.name,
      'status': status.name,
      'date': date,
      'zoneCount': zoneCount,
      'zoneNames': zoneNames,
      'summary': summary,
      'description': description,
      'format': format.name,
      'createdAt': createdAt.toIso8601String(),
      'indicators': indicators.toMap(),
    };
  }

  factory AdminReport.fromMap(Map<String, dynamic> map) {
    return AdminReport(
      id: map['id'] as String,
      analysisId: map['analysisId'] as String? ?? 'analysis_demo_default',
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
      description: map['description'] as String? ?? '',
      format: ReportFormat.values.firstWhere(
        (value) => value.name == map['format'],
        orElse: () => ReportFormat.pdf,
      ),
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      indicators: map['indicators'] is Map
          ? AnalysisIndicators.fromMap(
              Map<String, dynamic>.from(map['indicators'] as Map),
            )
          : const AnalysisIndicators(
              totalPoints: 0,
              average: 0,
              minimum: 0,
              maximum: 0,
              sum: 0,
              unit: 'pts',
            ),
    );
  }
}
