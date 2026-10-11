import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:clean237_frontend/data/repositories/admin_repository.dart';
import '../models/zone_model.dart';

enum ZoneSortOption {
  nameAsc('Nom (A-Z)'),
  scoreAsc('Score croissant'),
  scoreDesc('Score décroissant');

  final String label;
  const ZoneSortOption(this.label);
}

/// ViewModel pour la gestion de la liste des zones et des filtres
class ZonesViewModel extends ChangeNotifier {
  final AdminRepository _repository;
  late final StreamSubscription<void> _repositorySubscription;

  String _searchQuery = '';
  String _selectedFilter = 'Toutes';
  ZoneSortOption _sortOption = ZoneSortOption.nameAsc;

  final List<String> filters = const [
    'Toutes',
    'Normal',
    'À surveiller',
    'Critique',
  ];

  ZonesViewModel({
    required AdminRepository adminRepository,
    String? initialFilter,
  }) : _repository = adminRepository,
      _selectedFilter = initialFilter ?? 'Toutes' {
    _repositorySubscription = _repository.changes.listen((_) {
      notifyListeners();
    });
  }

  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;
  ZoneSortOption get sortOption => _sortOption;

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

  void setFilter(String filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
    }
  }

  void setSortOption(ZoneSortOption option) {
    if (_sortOption != option) {
      _sortOption = option;
      notifyListeners();
    }
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedFilter = 'Toutes';
    _sortOption = ZoneSortOption.nameAsc;
    notifyListeners();
  }

  /// Zones filtrées et triées
  List<Zone> get filteredZones {
    final allZones = _repository.allZones;

    final result = allZones.where((zone) {
      // Filtrage par statut
      if (_selectedFilter == 'Normal' && zone.status != ZoneStatus.normal) {
        return false;
      }
      if (_selectedFilter == 'À surveiller' &&
          zone.status != ZoneStatus.warning) {
        return false;
      }
      if (_selectedFilter == 'Critique' && zone.status != ZoneStatus.critical) {
        return false;
      }

      // Filtrage par recherche
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.trim().toLowerCase();
        final matchesName = zone.name.toLowerCase().contains(query);
        final matchesInterpretation = zone.interpretation
            .toLowerCase()
            .contains(query);
        if (!matchesName && !matchesInterpretation) {
          return false;
        }
      }

      return true;
    }).toList();

    // Tri
    switch (_sortOption) {
      case ZoneSortOption.nameAsc:
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
      case ZoneSortOption.scoreAsc:
        result.sort((a, b) => a.score.compareTo(b.score));
        break;
      case ZoneSortOption.scoreDesc:
        result.sort((a, b) => b.score.compareTo(a.score));
        break;
    }

    return result;
  }

  int get totalCount => _repository.allZones.length;
  int get filteredCount => filteredZones.length;

  @override
  void dispose() {
    unawaited(_repositorySubscription.cancel());
    super.dispose();
  }
}
