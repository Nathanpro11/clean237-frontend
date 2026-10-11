import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:clean237_frontend/data/repositories/admin_repository.dart';
import '../models/alert_model.dart';
import '../models/zone_model.dart';

/// ViewModel pour la page Détail d'une Zone
class ZoneDetailsViewModel extends ChangeNotifier {
  final AdminRepository _repository;
  final String zoneId;
  late final StreamSubscription<void> _repositorySubscription;

  final Set<String> _completedPriorities = {};

  ZoneDetailsViewModel({
    required this.zoneId,
    required AdminRepository adminRepository,
  }) : _repository = adminRepository {
    _repositorySubscription = _repository.changes.listen((_) {
      notifyListeners();
    });
  }

  Set<String> get completedPriorities => Set.unmodifiable(_completedPriorities);

  Zone? get zone => _repository.getZoneById(zoneId);

  List<AdminAlert> get alerts => _repository.getAlertsForZone(zoneId);

  bool isPriorityCompleted(String priority) =>
      _completedPriorities.contains(priority);

  void togglePriority(String priority) {
    if (_completedPriorities.contains(priority)) {
      _completedPriorities.remove(priority);
    } else {
      _completedPriorities.add(priority);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_repositorySubscription.cancel());
    super.dispose();
  }
}
