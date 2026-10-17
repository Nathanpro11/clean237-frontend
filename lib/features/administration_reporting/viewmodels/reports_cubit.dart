import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/exceptions/app_exception.dart';
import '../../../data/repositories/admin_repository.dart';
import '../models/report_model.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit(this._repository, {bool loadOnCreate = true})
    : super(const ReportsState()) {
    if (loadOnCreate) load();
  }

  final AdminRepository _repository;

  static const statusFilters = ['Tous', 'Prêt', 'En cours', 'Archivé'];

  String get selectedStatus => state.selectedStatus;
  String get searchQuery => state.searchQuery;
  List<AdminReport> get filteredReports => state.reports;
  int get totalCount => state.totalCount;

  String? get _status => switch (state.selectedStatus) {
    'Prêt' => 'pret',
    'En cours' => 'en_cours',
    'Archivé' => 'archive',
    _ => null,
  };

  Future<void> load() async {
    emit(state.copyWith(status: ReportsStatus.loading));
    try {
      final result = await _repository.getReports(
        page: 1,
        search: state.searchQuery,
        status: _status,
        type: state.selectedType,
        sort: state.sort,
        order: state.order,
      );
      emit(
        state.copyWith(
          status: result.items.isEmpty ? ReportsStatus.empty : ReportsStatus.success,
          reports: List.unmodifiable(result.items),
          totalCount: result.pagination.total,
          page: result.pagination.page,
          totalPages: result.pagination.totalPages,
          clearError: true,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(status: ReportsStatus.failure, errorMessage: error.message),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(status: ReportsStatus.failure, errorMessage: error.toString()),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.page >= state.totalPages || state.status == ReportsStatus.loading) {
      return;
    }
    try {
      final result = await _repository.getReports(
        page: state.page + 1,
        search: state.searchQuery,
        status: _status,
        type: state.selectedType,
        sort: state.sort,
        order: state.order,
      );
      final reports = [...state.reports, ...result.items];
      emit(
        state.copyWith(
          status: reports.isEmpty ? ReportsStatus.empty : ReportsStatus.success,
          reports: List.unmodifiable(reports),
          totalCount: result.pagination.total,
          page: result.pagination.page,
          totalPages: result.pagination.totalPages,
          clearError: true,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(status: ReportsStatus.failure, errorMessage: error.message),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(status: ReportsStatus.failure, errorMessage: error.toString()),
      );
    }
  }

  void setStatusFilter(String value) {
    emit(state.copyWith(selectedStatus: value));
    load();
  }

  void setSearchQuery(String value) {
    emit(state.copyWith(searchQuery: value));
    load();
  }

  void setSort({required String sort, required String order}) {
    emit(state.copyWith(sort: sort, order: order));
    load();
  }

  void resetFilters() {
    emit(state.copyWith(selectedStatus: 'Tous', searchQuery: ''));
    load();
  }

  Future<AdminReport> getReportById(String id) =>
      _repository.getReportById(id);

  Future<void> loadReport(String id) async {
    emit(
      state.copyWith(
        status: ReportsStatus.loading,
        clearReport: true,
        clearError: true,
      ),
    );
    try {
      final report = await _repository.getReportById(id);
      emit(
        state.copyWith(
          status: ReportsStatus.success,
          reportDetails: report,
          clearError: true,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: ReportsStatus.failure,
          errorMessage: error.message,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: ReportsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<AdminReport> setReportStatus(
    String id,
    ReportStatus status,
  ) async {
    final result = await _repository.updateReportStatus(id, status);
    final report = result.data;
    final reports = state.reports
        .map((item) => item.id == report.id ? report : item)
        .toList(growable: false);
    emit(state.copyWith(
      reports: List.unmodifiable(reports),
      successMessage: result.message ?? 'Statut du rapport mis à jour avec succès.',
      clearError: true,
    ));
    if (state.reportDetails?.id == report.id) {
      emit(state.copyWith(
        reportDetails: report,
        successMessage: result.message ?? 'Statut du rapport mis à jour avec succès.',
      ));
    }
    return report;
  }

  Future<String?> deleteReport(String id) async {
    final message = await _repository.deleteReport(id);
    final remainingReports = List<AdminReport>.unmodifiable(
      state.reports.where((report) => report.id != id),
    );
    emit(
      state.copyWith(
        status: remainingReports.isEmpty ? ReportsStatus.empty : state.status,
        reports: remainingReports,
        totalCount: (state.totalCount - 1).clamp(0, 9999999),
        clearReport: state.reportDetails?.id == id,
        successMessage: message ?? 'Rapport supprimé avec succès.',
        clearError: true,
      ),
    );
    return message;
  }
}
