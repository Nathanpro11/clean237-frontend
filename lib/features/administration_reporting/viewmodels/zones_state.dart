import 'package:equatable/equatable.dart';

import '../models/zone_model.dart';

enum ZonesStatus { initial, loading, success, failure }

enum ZoneSortOption {
  nameAsc('Nom (A-Z)'),
  scoreAsc('Score croissant'),
  scoreDesc('Score décroissant');

  const ZoneSortOption(this.label);
  final String label;
}

class ZonesState extends Equatable {
  const ZonesState({
    this.status = ZonesStatus.initial,
    this.zones = const [],
    this.searchQuery = '',
    this.selectedFilter = 'Toutes',
    this.sortOption = ZoneSortOption.nameAsc,
    this.totalCount = 0,
    this.errorMessage,
  });

  final ZonesStatus status;
  final List<Zone> zones;
  final String searchQuery;
  final String selectedFilter;
  final ZoneSortOption sortOption;
  final int totalCount;
  final String? errorMessage;

  ZonesState copyWith({
    ZonesStatus? status,
    List<Zone>? zones,
    String? searchQuery,
    String? selectedFilter,
    ZoneSortOption? sortOption,
    int? totalCount,
    String? errorMessage,
    bool clearError = false,
  }) => ZonesState(
    status: status ?? this.status,
    zones: zones ?? this.zones,
    searchQuery: searchQuery ?? this.searchQuery,
    selectedFilter: selectedFilter ?? this.selectedFilter,
    sortOption: sortOption ?? this.sortOption,
    totalCount: totalCount ?? this.totalCount,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    status,
    zones,
    searchQuery,
    selectedFilter,
    sortOption,
    totalCount,
    errorMessage,
  ];
}
