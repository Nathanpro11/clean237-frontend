import 'package:flutter/foundation.dart';

import 'package:clean237_frontend/data/repositories/admin_repository.dart';
import '../models/alert_model.dart';
import '../models/zone_model.dart';

/// ViewModel pour la page Détail d'une Zone
class ZoneDetailsViewModel extends ChangeNotifier {
  final AdminRepository _repository;
  final String zoneId;

  final Set<String> _completedPriorities = {};

  ZoneDetailsViewModel({required this.zoneId, AdminRepository? repository})
    : _repository = repository ?? AdminRepository.instance {
    _repository.addListener(_onRepositoryChanged);
  }

  Set<String> get completedPriorities => Set.unmodifiable(_completedPriorities);

  void _onRepositoryChanged() {
    notifyListeners();
  }

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
    _repository.removeListener(_onRepositoryChanged);
    super.dispose();
  }
}
