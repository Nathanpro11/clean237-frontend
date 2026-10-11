import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/admin_repository.dart';
import '../models/report_model.dart';
import '../models/zone_model.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit(this._repository) : super(const ReportsState()) {
    _subscription = _repository.changes.listen((_) => load());
    load();
  }

  final AdminRepository _repository;
  late final StreamSubscription<void> _subscription;

  static const statusFilters = ['Tous', 'Prêt', 'En cours', 'Archivé'];

  String get selectedStatus => state.selectedStatus;
  String get searchQuery => state.searchQuery;
  List<AdminReport> get filteredReports => state.reports;
  int get totalCount => state.totalCount;

  void load() {
    emit(state.copyWith(status: ReportsStatus.loading));
    try {
      final query = state.searchQuery.trim().toLowerCase();
      final reports = _repository.getReports().where((report) {
        if (state.selectedStatus == 'Prêt' &&
            report.status != ReportStatus.ready) {
          return false;
        }
        if (state.selectedStatus == 'En cours' &&
            report.status != ReportStatus.inProgress) {
          return false;
        }
        if (state.selectedStatus == 'Archivé' &&
            report.status != ReportStatus.archived) {
          return false;
        }
        return query.isEmpty ||
            report.title.toLowerCase().contains(query) ||
            report.summary.toLowerCase().contains(query);
      }).toList();
      emit(
        state.copyWith(
          status: ReportsStatus.success,
          reports: List.unmodifiable(reports),
          totalCount: _repository.getReports().length,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ReportsStatus.failure,
          errorMessage: error.toString(),
        ),
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

  void resetFilters() {
    emit(state.copyWith(selectedStatus: 'Tous', searchQuery: ''));
    load();
  }

  AdminReport? getReportById(String id) => _repository.getReportById(id);

  Zone? getZoneByName(String name) {
    for (final zone in _repository.getZones()) {
      if (zone.name == name) return zone;
    }
    return null;
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
