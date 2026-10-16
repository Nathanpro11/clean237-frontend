import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/admin_repository.dart';
import '../models/zone_model.dart';
import 'zones_state.dart';

class ZonesCubit extends Cubit<ZonesState> {
  ZonesCubit(this._repository, {String? initialFilter})
    : super(ZonesState(selectedFilter: initialFilter ?? 'Tous')) {
    load();
  }

  final AdminRepository _repository;

  static const filters = ['Tous', 'Critiques', 'À surveiller', 'Normal'];

  String get searchQuery => state.searchQuery;
  String get selectedFilter => state.selectedFilter;
  ZoneSortOption get sortOption => state.sortOption;
  List<Zone> get filteredZones => state.zones;
  int get totalCount => state.totalCount;

  Future<void> load() async {
    emit(state.copyWith(status: ZonesStatus.loading));
    try {
      final allZones = await _repository.getProblematicZones();
      final query = state.searchQuery.trim().toLowerCase();
      final result = allZones.where((zone) {
        final filter = state.selectedFilter;
        if (filter == 'Normal' &&
            zone.status != ZoneStatus.normal) {
          return false;
        }
        if (filter == 'À surveiller' &&
            zone.status != ZoneStatus.warning) {
          return false;
        }
        if ((filter == 'Critiques' || filter == 'Critique') &&
            zone.status != ZoneStatus.critical) {
          return false;
        }
        return query.isEmpty ||
            zone.name.toLowerCase().contains(query);
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
          status: result.isEmpty ? ZonesStatus.empty : ZonesStatus.success,
          zones: List.unmodifiable(result),
          totalCount: allZones.length,
          clearError: true,
        ),
      );
    } on Object catch (error) {
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
        selectedFilter: 'Tous',
        sortOption: ZoneSortOption.nameAsc,
      ),
    );
    load();
  }

}
