import 'package:equatable/equatable.dart';

import '../models/report_model.dart';

enum ReportsStatus { initial, loading, success, empty, failure }

class ReportsState extends Equatable {
  const ReportsState({
    this.status = ReportsStatus.initial,
    this.reports = const [],
    this.selectedStatus = 'Tous',
    this.sort = 'createdAt',
    this.order = 'desc',
    this.searchQuery = '',
    this.totalCount = 0,
    this.page = 1,
    this.totalPages = 1,
    this.selectedType,
    this.reportDetails,
    this.errorMessage,
    this.successMessage,
  });

  final ReportsStatus status;
  final List<AdminReport> reports;
  final String selectedStatus;
  final String sort;
  final String order;
  final String searchQuery;
  final int totalCount;
  final int page;
  final int totalPages;
  final String? selectedType;
  final AdminReport? reportDetails;
  final String? errorMessage;
  final String? successMessage;

  ReportsState copyWith({
    ReportsStatus? status,
    List<AdminReport>? reports,
    String? selectedStatus,
    String? sort,
    String? order,
    String? searchQuery,
    int? totalCount,
    int? page,
    int? totalPages,
    String? selectedType,
    AdminReport? reportDetails,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearReport = false,
  }) => ReportsState(
    status: status ?? this.status,
    reports: reports ?? this.reports,
    selectedStatus: selectedStatus ?? this.selectedStatus,
    sort: sort ?? this.sort,
    order: order ?? this.order,
    searchQuery: searchQuery ?? this.searchQuery,
    totalCount: totalCount ?? this.totalCount,
    page: page ?? this.page,
    totalPages: totalPages ?? this.totalPages,
    selectedType: selectedType ?? this.selectedType,
    reportDetails: clearReport ? null : reportDetails ?? this.reportDetails,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    successMessage: clearSuccess ? null : successMessage ?? this.successMessage,
  );

  @override
  List<Object?> get props => [
    status,
    reports,
    selectedStatus,
    sort,
    order,
    searchQuery,
    totalCount,
    page,
    totalPages,
    selectedType,
    reportDetails,
    errorMessage,
    successMessage,
  ];
}
