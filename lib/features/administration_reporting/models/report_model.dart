import 'package:intl/intl.dart';

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

class ReportZone {
  const ReportZone({required this.id, required this.name});

  final String id;
  final String name;
}

class AdminReport {
  const AdminReport({
    required this.id,
    required this.title,
    required this.typeName,
    required this.status,
    required this.format,
    required this.zones,
    required this.analysisId,
    required this.createdAt,
    this.description,
    this.indicators,
  });

  final String id;
  final String title;
  final String typeName;
  final ReportStatus status;
  final ReportFormat format;
  final List<ReportZone> zones;
  final String? analysisId;
  final DateTime createdAt;
  final String? description;
  final AnalysisIndicators? indicators;

  ReportType get type => switch (typeName.toLowerCase()) {
    'suivi' || 'tracking' => ReportType.tracking,
    'export' => ReportType.export,
    _ => ReportType.synthesis,
  };

  String get date => DateFormat('dd/MM/yyyy').format(createdAt.toLocal());
  int get zoneCount => zones.length;
  List<String> get zoneNames => zones.map((zone) => zone.name).toList();
  String get summary => description ?? '';

  AdminReport copyWith({
    String? id,
    String? title,
    String? typeName,
    ReportStatus? status,
    ReportFormat? format,
    List<ReportZone>? zones,
    String? analysisId,
    DateTime? createdAt,
    String? description,
    AnalysisIndicators? indicators,
  }) => AdminReport(
    id: id ?? this.id,
    title: title ?? this.title,
    typeName: typeName ?? this.typeName,
    status: status ?? this.status,
    format: format ?? this.format,
    zones: zones ?? this.zones,
    analysisId: analysisId ?? this.analysisId,
    createdAt: createdAt ?? this.createdAt,
    description: description ?? this.description,
    indicators: indicators ?? this.indicators,
  );
}
