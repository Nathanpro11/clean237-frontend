import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/dto/dashboard_dto.dart';
import '../../../data/repositories/admin_repository.dart';
import '../models/alert_model.dart';
import '../models/zone_model.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository) : super(const DashboardState()) {
    load();
  }

  final AdminRepository _repository;

  int get totalZonesCount => state.totalZonesCount;
  int get criticalZonesCount => state.criticalZonesCount;
  int get activeAlertsCount => state.activeAlertsCount;
  int get totalReportsCount => state.totalReportsCount;
  List<Zone> get zonesToWatch => state.zonesToWatch;
  List<AdminAlert> get recentAlerts => state.recentAlerts;

  Future<void> load() async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final DashboardDto dashboard = await _repository.getDashboard();
      final zones = await _repository.getProblematicZones();
      final alerts = await _repository.getAlerts(
        status: 'active',
        page: 1,
        limit: 3,
      );
      emit(
        state.copyWith(
          status: DashboardStatus.success,
          totalZonesCount: dashboard.totalZones,
          criticalZonesCount: dashboard.zonesCritiques,
          activeAlertsCount: dashboard.alertesActives,
          totalReportsCount: dashboard.totalReports,
          zonesToWatch: List.unmodifiable(
            zones.where((zone) => zone.status != ZoneStatus.normal).take(3),
          ),
          recentAlerts: List.unmodifiable(alerts.items),
          clearError: true,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
