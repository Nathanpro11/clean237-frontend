import 'package:equatable/equatable.dart';

import '../models/alert_model.dart';

enum AlertsStatus { initial, loading, success, empty, failure }

class AlertsState extends Equatable {
  const AlertsState({
    this.status = AlertsStatus.initial,
    this.alerts = const [],
    this.selectedFilter = 'Toutes',
    this.selectedStatus = 'active',
    this.searchQuery = '',
    this.totalCount = 0,
    this.activeCount = 0,
    this.page = 1,
    this.totalPages = 1,
    this.alertDetails,
    this.errorMessage,
    this.resolutionMessage,
  });

  final AlertsStatus status;
  final List<AdminAlert> alerts;
  final String selectedFilter;
  final String selectedStatus;
  final String searchQuery;
  final int totalCount;
  final int activeCount;
  final int page;
  final int totalPages;
  final AdminAlert? alertDetails;
  final String? errorMessage;
  final String? resolutionMessage;

  String? get successMessage => resolutionMessage;

  AlertsState copyWith({
    AlertsStatus? status,
    List<AdminAlert>? alerts,
    String? selectedFilter,
    String? selectedStatus,
    String? searchQuery,
    int? totalCount,
    int? activeCount,
    int? page,
    int? totalPages,
    AdminAlert? alertDetails,
    String? errorMessage,
    String? resolutionMessage,
    bool clearError = false,
    bool clearResolution = false,
    bool clearAlert = false,
  }) => AlertsState(
    status: status ?? this.status,
    alerts: alerts ?? this.alerts,
    selectedFilter: selectedFilter ?? this.selectedFilter,
    selectedStatus: selectedStatus ?? this.selectedStatus,
    searchQuery: searchQuery ?? this.searchQuery,
    totalCount: totalCount ?? this.totalCount,
    activeCount: activeCount ?? this.activeCount,
    page: page ?? this.page,
    totalPages: totalPages ?? this.totalPages,
    alertDetails: clearAlert ? null : alertDetails ?? this.alertDetails,
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
    selectedStatus,
    searchQuery,
    totalCount,
    activeCount,
    page,
    totalPages,
    alertDetails,
    errorMessage,
    resolutionMessage,
  ];
}
