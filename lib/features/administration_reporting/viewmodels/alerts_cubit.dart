import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/admin_repository.dart';
import '../models/alert_model.dart';
import 'alerts_state.dart';

class AlertsCubit extends Cubit<AlertsState> {
  AlertsCubit(this._repository) : super(const AlertsState()) {
    _subscription = _repository.changes.listen((_) => load());
    load();
  }

  final AdminRepository _repository;
  late final StreamSubscription<void> _subscription;

  static const filters = ['Toutes', 'Critiques', 'À surveiller'];

  String get selectedFilter => state.selectedFilter;
  String get searchQuery => state.searchQuery;
  List<AdminAlert> get filteredAlerts => state.alerts;
  int get totalCount => state.totalCount;
  int get activeCount => state.activeCount;

  void load() {
    emit(state.copyWith(status: AlertsStatus.loading));
    try {
      final query = state.searchQuery.trim().toLowerCase();
      final alerts = _repository.getAlerts().where((alert) {
        if (state.selectedFilter == 'Critiques' &&
            alert.severity != AlertSeverity.critical) {
          return false;
        }
        if (state.selectedFilter == 'À surveiller' &&
            alert.severity != AlertSeverity.warning) {
          return false;
        }
        return query.isEmpty ||
            alert.title.toLowerCase().contains(query) ||
            alert.zoneName.toLowerCase().contains(query) ||
            alert.context.toLowerCase().contains(query);
      }).toList();
      emit(
        state.copyWith(
          status: AlertsStatus.success,
          alerts: List.unmodifiable(alerts),
          totalCount: _repository.getAlerts().length,
          activeCount: _repository.activeAlerts.length,
          clearError: true,
        ),
      );
    } catch (error) {
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

  void setSearchQuery(String value) {
    emit(state.copyWith(searchQuery: value));
    load();
  }

  void resetFilters() {
    emit(state.copyWith(selectedFilter: 'Toutes', searchQuery: ''));
    load();
  }

  AdminAlert? getAlertById(String id) => _repository.getAlertById(id);

  void resolveAlert(String id, String actionLabel) {
    _repository.markAlertAsHandled(id);
    emit(
      state.copyWith(
        resolutionMessage:
            'L’action "$actionLabel" a été validée avec succès.',
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
