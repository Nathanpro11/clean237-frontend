import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/admin_repository.dart';
import '../models/zone_model.dart';
import 'zones_state.dart';

class ZonesCubit extends Cubit<ZonesState> {
  ZonesCubit(this._repository, {String? initialFilter})
    : super(ZonesState(selectedFilter: initialFilter ?? 'Toutes')) {
    _subscription = _repository.changes.listen((_) => load());
    load();
  }

  final AdminRepository _repository;
  late final StreamSubscription<void> _subscription;

  static const filters = ['Toutes', 'Normal', 'À surveiller', 'Critique'];

  String get searchQuery => state.searchQuery;
  String get selectedFilter => state.selectedFilter;
  ZoneSortOption get sortOption => state.sortOption;
  List<Zone> get filteredZones => state.zones;
  int get totalCount => state.totalCount;

  void load() {
    emit(state.copyWith(status: ZonesStatus.loading));
    try {
      final query = state.searchQuery.trim().toLowerCase();
      final result = _repository.getZones().where((zone) {
        if (state.selectedFilter == 'Normal' &&
            zone.status != ZoneStatus.normal) {
          return false;
        }
        if (state.selectedFilter == 'À surveiller' &&
            zone.status != ZoneStatus.warning) {
          return false;
        }
        if (state.selectedFilter == 'Critique' &&
            zone.status != ZoneStatus.critical) {
          return false;
        }
        return query.isEmpty ||
            zone.name.toLowerCase().contains(query) ||
            zone.interpretation.toLowerCase().contains(query);
      }).toList();
      switch (state.sortOption) {
        case ZoneSortOption.nameAsc:
          result.sort((a, b) => a.name.compareTo(b.name));
        case ZoneSortOption.scoreAsc:
          result.sort((a, b) => a.score.compareTo(b.score));
        case ZoneSortOption.scoreDesc:
          result.sort((a, b) => b.score.compareTo(a.score));
      }
      emit(
        state.copyWith(
          status: ZonesStatus.success,
          zones: List.unmodifiable(result),
          totalCount: _repository.getZones().length,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ZonesStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void setSearchQuery(String value) {
    if (value != state.searchQuery) {
      emit(state.copyWith(searchQuery: value));
      load();
    }
  }

  void clearSearchQuery() => setSearchQuery('');

  void setFilter(String value) {
    if (value != state.selectedFilter) {
      emit(state.copyWith(selectedFilter: value));
      load();
    }
  }

  void setSortOption(ZoneSortOption value) {
    if (value != state.sortOption) {
      emit(state.copyWith(sortOption: value));
      load();
    }
  }

  void resetFilters() {
    emit(
      state.copyWith(
        searchQuery: '',
        selectedFilter: 'Toutes',
        sortOption: ZoneSortOption.nameAsc,
      ),
    );
    load();
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
