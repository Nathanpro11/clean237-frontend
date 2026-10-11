import 'package:flutter/foundation.dart';

import 'package:clean237_frontend/data/repositories/admin_repository.dart';
import '../models/alert_model.dart';

/// ViewModel pour la gestion des alertes et résolutions
class AlertsViewModel extends ChangeNotifier {
  final AdminRepository _repository;

  String _selectedFilter = 'Toutes';
  String _searchQuery = '';

  final List<String> filters = const ['Toutes', 'Critiques', 'À surveiller'];

  AlertsViewModel({AdminRepository? repository})
    : _repository = repository ?? AdminRepository.instance {
    _repository.addListener(_onRepositoryChanged);
  }

  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;

  void _onRepositoryChanged() {
    notifyListeners();
  }

  void setFilter(String filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  void clearSearchQuery() {
    if (_searchQuery.isNotEmpty) {
      _searchQuery = '';
      notifyListeners();
    }
  }

  void resetFilters() {
    _selectedFilter = 'Toutes';
    _searchQuery = '';
    notifyListeners();
  }

  List<AdminAlert> get filteredAlerts {
    final allAlerts = _repository.allAlerts;

    return allAlerts.where((a) {
      if (_selectedFilter == 'Critiques' &&
          a.severity != AlertSeverity.critical) {
        return false;
      }
      if (_selectedFilter == 'À surveiller' &&
          a.severity != AlertSeverity.warning) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final matchesTitle = a.title.toLowerCase().contains(q);
        final matchesZone = a.zoneName.toLowerCase().contains(q);
        final matchesContext = a.context.toLowerCase().contains(q);
        if (!matchesTitle && !matchesZone && !matchesContext) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  int get totalCount => _repository.allAlerts.length;
  int get activeCount => _repository.activeAlerts.length;

  AdminAlert? getAlertById(String alertId) => _repository.getAlertById(alertId);

  void resolveAlert(String alertId) {
    _repository.markAlertAsHandled(alertId);
  }

  @override
  void dispose() {
    _repository.removeListener(_onRepositoryChanged);
    super.dispose();
  }
}
