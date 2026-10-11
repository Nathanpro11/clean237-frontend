import 'package:equatable/equatable.dart';

import '../models/alert_model.dart';
import '../models/zone_model.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.totalZonesCount = 0,
    this.criticalZonesCount = 0,
    this.activeAlertsCount = 0,
    this.totalReportsCount = 0,
    this.zonesToWatch = const [],
    this.recentAlerts = const [],
    this.errorMessage,
  });

  final DashboardStatus status;
  final int totalZonesCount;
  final int criticalZonesCount;
  final int activeAlertsCount;
  final int totalReportsCount;
  final List<Zone> zonesToWatch;
  final List<AdminAlert> recentAlerts;
  final String? errorMessage;

  DashboardState copyWith({
    DashboardStatus? status,
    int? totalZonesCount,
    int? criticalZonesCount,
    int? activeAlertsCount,
    int? totalReportsCount,
    List<Zone>? zonesToWatch,
    List<AdminAlert>? recentAlerts,
    String? errorMessage,
    bool clearError = false,
  }) => DashboardState(
    status: status ?? this.status,
    totalZonesCount: totalZonesCount ?? this.totalZonesCount,
    criticalZonesCount: criticalZonesCount ?? this.criticalZonesCount,
    activeAlertsCount: activeAlertsCount ?? this.activeAlertsCount,
    totalReportsCount: totalReportsCount ?? this.totalReportsCount,
    zonesToWatch: zonesToWatch ?? this.zonesToWatch,
    recentAlerts: recentAlerts ?? this.recentAlerts,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    status,
    totalZonesCount,
    criticalZonesCount,
    activeAlertsCount,
    totalReportsCount,
    zonesToWatch,
    recentAlerts,
    errorMessage,
  ];
}
