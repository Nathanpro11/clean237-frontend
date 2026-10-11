import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:clean237_frontend/data/repositories/admin_repository.dart';
import '../models/report_model.dart';
import '../models/zone_model.dart';

/// ViewModel pour la gestion de la liste des rapports
class ReportsViewModel extends ChangeNotifier {
  final AdminRepository _repository;
  late final StreamSubscription<void> _repositorySubscription;

  String _selectedStatus = 'Tous';
  String _searchQuery = '';

  final List<String> statusFilters = const [
    'Tous',
    'Prêt',
    'En cours',
    'Archivé',
  ];

  ReportsViewModel({required AdminRepository adminRepository})
    : _repository = adminRepository {
    _repositorySubscription = _repository.changes.listen((_) {
      notifyListeners();
    });
  }

  String get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;

  void setStatusFilter(String status) {
    if (_selectedStatus != status) {
      _selectedStatus = status;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  void resetFilters() {
    _selectedStatus = 'Tous';
    _searchQuery = '';
    notifyListeners();
  }

  List<AdminReport> get filteredReports {
    final all = _repository.allReports;

    return all.where((report) {
      if (_selectedStatus == 'Prêt' && report.status != ReportStatus.ready) {
        return false;
      }
      if (_selectedStatus == 'En cours' &&
          report.status != ReportStatus.inProgress) {
        return false;
      }
      if (_selectedStatus == 'Archivé' &&
          report.status != ReportStatus.archived) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final matchesTitle = report.title.toLowerCase().contains(q);
        final matchesSummary = report.summary.toLowerCase().contains(q);
        if (!matchesTitle && !matchesSummary) return false;
      }

      return true;
    }).toList();
  }

  int get totalCount => _repository.allReports.length;

  AdminReport? getReportById(String reportId) =>
      _repository.getReportById(reportId);

  Zone? getZoneByName(String zoneName) {
    for (final zone in _repository.allZones) {
      if (zone.name == zoneName) return zone;
    }
    return null;
  }

  @override
  void dispose() {
    unawaited(_repositorySubscription.cancel());
    super.dispose();
  }
}
