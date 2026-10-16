import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/exceptions/app_exception.dart';
import '../../../data/repositories/admin_repository.dart';
import '../models/alert_model.dart';
import 'alerts_state.dart';

class AlertsCubit extends Cubit<AlertsState> {
  AlertsCubit(this._repository) : super(const AlertsState()) {
    load();
  }

  final AdminRepository _repository;

  static const filters = ['Toutes', 'Critiques', 'À surveiller', 'Info'];
  static const statusFilters = ['Actives', 'Traitées', 'Toutes'];

  String get selectedFilter => state.selectedFilter;
  String get searchQuery => state.searchQuery;
  List<AdminAlert> get filteredAlerts => state.alerts;
  int get totalCount => state.totalCount;
  int get activeCount => state.activeCount;

  String? get _severity => switch (state.selectedFilter) {
    'Critiques' => 'critique',
    'À surveiller' => 'avertissement',
    'Info' => 'info',
    _ => null,
  };

  String? get _status => switch (state.selectedStatus) {
    'active' => 'active',
    'traitee' => 'traitee',
    _ => null,
  };

  Future<void> load() async {
    emit(state.copyWith(status: AlertsStatus.loading));
    try {
      final result = await _repository.getAlerts(
        severity: _severity,
        status: _status,
        search: state.searchQuery,
        page: 1,
      );
      emit(
        state.copyWith(
          status: result.items.isEmpty ? AlertsStatus.empty : AlertsStatus.success,
          alerts: List.unmodifiable(result.items),
          totalCount: result.pagination.total,
          activeCount: state.selectedStatus == 'active'
              ? result.pagination.total
              : 0,
          page: result.pagination.page,
          totalPages: result.pagination.totalPages,
          clearError: true,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: AlertsStatus.failure,
          errorMessage: error.message,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: AlertsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.page >= state.totalPages || state.status == AlertsStatus.loading) {
      return;
    }
    try {
      final result = await _repository.getAlerts(
        severity: _severity,
        status: _status,
        search: state.searchQuery,
        page: state.page + 1,
      );
      final allAlerts = [...state.alerts, ...result.items];
      emit(
        state.copyWith(
          status: allAlerts.isEmpty ? AlertsStatus.empty : AlertsStatus.success,
          alerts: List.unmodifiable(allAlerts),
          totalCount: result.pagination.total,
          page: result.pagination.page,
          totalPages: result.pagination.totalPages,
          clearError: true,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: AlertsStatus.failure,
          errorMessage: error.message,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: AlertsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void setFilter(String value) {
    emit(state.copyWith(selectedFilter: value));
    load();
  }

  void setStatusFilter(String value) {
    final status = switch (value) {
      'Actives' => 'active',
      'Traitées' => 'traitee',
      _ => 'all',
    };
    emit(state.copyWith(selectedStatus: status));
    load();
  }

  void setSearchQuery(String value) {
    emit(state.copyWith(searchQuery: value));
    load();
  }

  void resetFilters() {
    emit(
      state.copyWith(
        selectedFilter: 'Toutes',
        selectedStatus: 'active',
        searchQuery: '',
      ),
    );
    load();
  }

  Future<void> loadAlert(String id) async {
    emit(
      state.copyWith(
        status: AlertsStatus.loading,
        clearAlert: true,
        clearError: true,
      ),
    );
    try {
      final alert = await _repository.getAlertById(id);
      emit(
        state.copyWith(
          status: AlertsStatus.success,
          alertDetails: alert,
          clearError: true,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: AlertsStatus.failure,
          errorMessage: error.message,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: AlertsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> resolveAlert(String id) async {
    emit(state.copyWith(status: AlertsStatus.loading, clearError: true));
    try {
      final result = await _repository.treatAlert(id);
      final updatedAlert = result.data;
      final alerts = state.alerts
          .map((alert) => alert.id == id ? updatedAlert : alert)
          .toList(growable: false);
      emit(
        state.copyWith(
          status: AlertsStatus.success,
          alerts: List.unmodifiable(alerts),
          alertDetails: updatedAlert,
          resolutionMessage: result.message ?? 'Alerte traitée avec succès.',
          clearError: true,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: AlertsStatus.failure,
          errorMessage: error.message,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: AlertsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
