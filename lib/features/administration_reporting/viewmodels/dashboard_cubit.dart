import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/admin_repository.dart';
import '../models/alert_model.dart';
import '../models/zone_model.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository) : super(const DashboardState()) {
    _subscription = _repository.changes.listen((_) => load());
    load();
  }

  final AdminRepository _repository;
  late final StreamSubscription<void> _subscription;

  int get totalZonesCount => state.totalZonesCount;
  int get criticalZonesCount => state.criticalZonesCount;
  int get activeAlertsCount => state.activeAlertsCount;
  int get totalReportsCount => state.totalReportsCount;
  List<Zone> get zonesToWatch => state.zonesToWatch;
  List<AdminAlert> get recentAlerts => state.recentAlerts;

  void load() {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      emit(
        state.copyWith(
          status: DashboardStatus.success,
          totalZonesCount: _repository.getZones().length,
          criticalZonesCount: _repository.criticalZones.length,
          activeAlertsCount: _repository.activeAlerts.length,
          totalReportsCount: _repository.getReports().length,
          zonesToWatch: List.unmodifiable(_repository.zonesToWatch),
          recentAlerts: List.unmodifiable(
            _repository.activeAlerts.take(3).toList(),
          ),
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
