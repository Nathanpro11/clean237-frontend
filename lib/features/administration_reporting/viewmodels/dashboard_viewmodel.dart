import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:clean237_frontend/data/repositories/admin_repository.dart';
import '../models/alert_model.dart';
import '../models/zone_model.dart';

/// ViewModel pour la page Tableau de bord (Dashboard)
class DashboardViewModel extends ChangeNotifier {
  final AdminRepository _repository;
  late final StreamSubscription<void> _repositorySubscription;

  DashboardViewModel({required AdminRepository adminRepository})
    : _repository = adminRepository {
    _repositorySubscription = _repository.changes.listen((_) {
      notifyListeners();
    });
  }

  // Données observables
  int get totalZonesCount => _repository.allZones.length;
  int get criticalZonesCount => _repository.criticalZones.length;
  int get activeAlertsCount => _repository.activeAlerts.length;
  int get totalReportsCount => _repository.allReports.length;

  List<Zone> get zonesToWatch => _repository.zonesToWatch;
  List<AdminAlert> get recentAlerts =>
      _repository.activeAlerts.take(3).toList();

  @override
  void dispose() {
    unawaited(_repositorySubscription.cancel());
    super.dispose();
  }
}
