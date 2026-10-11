import 'package:equatable/equatable.dart';

import '../models/report_model.dart';

enum ReportsStatus { initial, loading, success, failure }

class ReportsState extends Equatable {
  const ReportsState({
    this.status = ReportsStatus.initial,
    this.reports = const [],
    this.selectedStatus = 'Tous',
    this.searchQuery = '',
    this.totalCount = 0,
    this.errorMessage,
  });

  final ReportsStatus status;
  final List<AdminReport> reports;
  final String selectedStatus;
  final String searchQuery;
  final int totalCount;
  final String? errorMessage;

  ReportsState copyWith({
    ReportsStatus? status,
    List<AdminReport>? reports,
    String? selectedStatus,
    String? searchQuery,
    int? totalCount,
    String? errorMessage,
    bool clearError = false,
  }) => ReportsState(
    status: status ?? this.status,
    reports: reports ?? this.reports,
    selectedStatus: selectedStatus ?? this.selectedStatus,
    searchQuery: searchQuery ?? this.searchQuery,
    totalCount: totalCount ?? this.totalCount,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    status,
    reports,
    selectedStatus,
    searchQuery,
    totalCount,
    errorMessage,
  ];
}
