import 'package:equatable/equatable.dart';

import '../models/alert_model.dart';

enum AlertsStatus { initial, loading, success, failure }

class AlertsState extends Equatable {
  const AlertsState({
    this.status = AlertsStatus.initial,
    this.alerts = const [],
    this.selectedFilter = 'Toutes',
    this.searchQuery = '',
    this.totalCount = 0,
    this.activeCount = 0,
    this.errorMessage,
    this.resolutionMessage,
  });

  final AlertsStatus status;
  final List<AdminAlert> alerts;
  final String selectedFilter;
  final String searchQuery;
  final int totalCount;
  final int activeCount;
  final String? errorMessage;
  final String? resolutionMessage;

  AlertsState copyWith({
    AlertsStatus? status,
    List<AdminAlert>? alerts,
    String? selectedFilter,
    String? searchQuery,
    int? totalCount,
    int? activeCount,
    String? errorMessage,
    String? resolutionMessage,
    bool clearError = false,
    bool clearResolution = false,
  }) => AlertsState(
    status: status ?? this.status,
    alerts: alerts ?? this.alerts,
    selectedFilter: selectedFilter ?? this.selectedFilter,
    searchQuery: searchQuery ?? this.searchQuery,
    totalCount: totalCount ?? this.totalCount,
    activeCount: activeCount ?? this.activeCount,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    resolutionMessage: clearResolution
        ? null
        : resolutionMessage ?? this.resolutionMessage,
  );

  @override
  List<Object?> get props => [
    status,
    alerts,
    selectedFilter,
    searchQuery,
    totalCount,
    activeCount,
    errorMessage,
    resolutionMessage,
  ];
}
