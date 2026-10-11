import 'package:flutter/foundation.dart';

import '../../features/administration_reporting/models/alert_model.dart';
import '../../features/administration_reporting/models/report_model.dart';
import '../../features/administration_reporting/models/zone_model.dart';
import '../services/admin_mock_data_source.dart';

/// Repository en mémoire des données du module d'administration.
class AdminRepository extends ChangeNotifier {
  static final AdminRepository instance = AdminRepository._internal();
  factory AdminRepository() => instance;
  AdminRepository._internal();

  final AdminMockDataSource _dataSource = AdminMockDataSource();

  // Getters
  List<Zone> get allZones => List.unmodifiable(_dataSource.zones);
  List<Zone> get criticalZones =>
      _dataSource.zones.where((z) => z.status == ZoneStatus.critical).toList();
  List<Zone> get warningZones =>
      _dataSource.zones.where((z) => z.status == ZoneStatus.warning).toList();
  List<Zone> get zonesToWatch => _dataSource.zones
      .where((z) => z.status != ZoneStatus.normal)
      .take(2)
      .toList();

  List<AdminAlert> get allAlerts => List.unmodifiable(_dataSource.alerts);
  List<AdminAlert> get activeAlerts =>
      _dataSource.alerts.where((a) => !a.isHandled).toList();
  List<AdminAlert> getAlertsForZone(String zoneId) =>
      _dataSource.alerts.where((a) => a.zoneId == zoneId).toList();

  List<AdminReport> get allReports => List.unmodifiable(_dataSource.reports);

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
      notifyListeners();
    }
  }

  void addReport(AdminReport report) {
    _dataSource.reports.insert(0, report);
    notifyListeners();
  }
}
