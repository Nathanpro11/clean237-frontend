import 'dart:async';

import '../../features/administration_reporting/models/alert_model.dart';
import '../../features/administration_reporting/models/analysis_model.dart';
import '../../features/administration_reporting/models/report_model.dart';
import '../../features/administration_reporting/models/zone_model.dart';
import '../services/admin_mock_data_source.dart';

class AdminRepositoryException implements Exception {
  const AdminRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Repository en mémoire des données du module d'administration.
class AdminRepository {
  AdminRepository({AdminMockDataSource? dataSource})
    : _dataSource = dataSource ?? AdminMockDataSource();

  final AdminMockDataSource _dataSource;
  final StreamController<void> _changesController =
      StreamController<void>.broadcast();

  Stream<void> get changes => _changesController.stream;

  // Getters
  List<Zone> getZones() => allZones;

  List<Zone> get allZones => List.unmodifiable(_dataSource.zones);
  List<Zone> get criticalZones =>
      _dataSource.zones.where((z) => z.status == ZoneStatus.critical).toList();
  List<Zone> get warningZones =>
      _dataSource.zones.where((z) => z.status == ZoneStatus.warning).toList();
  List<Zone> get zonesToWatch => _dataSource.zones
      .where((z) => z.status != ZoneStatus.normal)
      .take(2)
      .toList();

  List<AdminAlert> getAlerts() => allAlerts;

  List<AdminAlert> get allAlerts => List.unmodifiable(_dataSource.alerts);
  List<AdminAlert> get activeAlerts =>
      _dataSource.alerts.where((a) => !a.isHandled).toList();
  List<AdminAlert> getAlertsForZone(String zoneId) =>
      _dataSource.alerts.where((a) => a.zoneId == zoneId).toList();

  List<AdminReport> getReports() => allReports;

  List<AdminReport> get allReports => List.unmodifiable(_dataSource.reports);
  List<Analysis> get analyses => List.unmodifiable(_dataSource.analyses);

  Zone? getZoneById(String id) {
    try {
      return _dataSource.zones.firstWhere((z) => z.id == id);
    } catch (_) {
      return null;
    }
  }

  AdminAlert? getAlertById(String id) {
    try {
      return _dataSource.alerts.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  AdminReport? getReportById(String id) {
    try {
      return _dataSource.reports.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  void markAlertAsHandled(String alertId) {
    final index = _dataSource.alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      _dataSource.alerts[index] = _dataSource.alerts[index].copyWith(
        isHandled: true,
      );
      _changesController.add(null);
    }
  }

  Analysis? getAnalysisById(String id) {
    try {
      return _dataSource.analyses.firstWhere((analysis) => analysis.id == id);
    } on StateError {
      return null;
    }
  }

  Analysis generateAnalysis({
    required DateTime? periodStart,
    required DateTime? periodEnd,
    required List<String> zoneIds,
    String type = 'Analyse de propreté',
  }) {
    if (periodStart == null || periodEnd == null) {
      throw const AdminRepositoryException(
        'La période de l’analyse est obligatoire.',
      );
    }
    if (zoneIds.isEmpty) {
      throw const AdminRepositoryException(
        'Sélectionnez au moins une zone pour lancer l’analyse.',
      );
    }
    if (periodStart.isAfter(periodEnd)) {
      throw const AdminRepositoryException(
        'La date de début doit précéder ou être égale à la date de fin.',
      );
    }
    final now = DateTime.now();
    if (DateTime(periodEnd.year, periodEnd.month, periodEnd.day).isAfter(
      DateTime(now.year, now.month, now.day),
    )) {
      throw const AdminRepositoryException(
        'La date de fin ne peut pas être située dans le futur.',
      );
    }
    final selectedZones = <Zone>[];
    for (final zoneId in zoneIds.toSet()) {
      final zone = getZoneById(zoneId);
      if (zone == null) {
        throw AdminRepositoryException(
          'La zone "$zoneId" est introuvable.',
        );
      }
      selectedZones.add(zone);
    }

    final scores = selectedZones.map((zone) => zone.score).toList();
    final sum = scores.fold<int>(0, (total, score) => total + score);
    final average = sum / scores.length;
    final analysis = Analysis(
      id: 'analysis_${now.microsecondsSinceEpoch}',
      type: type,
      periodStart: periodStart,
      periodEnd: periodEnd,
      zoneIds: List.unmodifiable(selectedZones.map((zone) => zone.id)),
      result:
          'Le score moyen des ${scores.length} zones analysées est de '
          '${average.toStringAsFixed(1)} pts sur la période sélectionnée.',
      indicators: AnalysisIndicators(
        totalPoints: scores.length,
        average: average,
        minimum: scores.reduce((a, b) => a < b ? a : b),
        maximum: scores.reduce((a, b) => a > b ? a : b),
        sum: sum,
        unit: 'pts',
      ),
      createdAt: now,
    );
    _dataSource.analyses.insert(0, analysis);
    _changesController.add(null);
    return analysis;
  }

  AdminReport generateReport({
    required String analysisId,
    required String title,
    required String description,
    required ReportFormat format,
  }) {
    final analysis = getAnalysisById(analysisId);
    if (analysis == null) {
      throw const AdminRepositoryException(
        'Une analyse valide est nécessaire pour créer un rapport.',
      );
    }
    final selectedZones = analysis.zoneIds
        .map(getZoneById)
        .whereType<Zone>()
        .toList(growable: false);
    final now = DateTime.now();
    final report = AdminReport(
      id: 'report_${now.microsecondsSinceEpoch}',
      analysisId: analysis.id,
      title: title,
      description: description,
      type: ReportType.synthesis,
      status: ReportStatus.ready,
      date: 'Aujourd’hui',
      createdAt: now,
      zoneCount: analysis.indicators.totalPoints,
      zoneNames: List.unmodifiable(selectedZones.map((zone) => zone.name)),
      summary: description.isNotEmpty ? description : analysis.result,
      format: format,
      indicators: analysis.indicators,
    );
    _dataSource.reports.insert(0, report);
    _changesController.add(null);
    return report;
  }

  void dispose() {
    unawaited(_changesController.close());
  }
}
