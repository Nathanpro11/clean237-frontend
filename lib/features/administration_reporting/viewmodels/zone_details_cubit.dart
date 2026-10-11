import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/admin_repository.dart';
import '../models/alert_model.dart';
import '../models/zone_model.dart';

enum ZoneDetailsStatus { initial, loading, success, failure }

class ZoneDetailsState extends Equatable {
  const ZoneDetailsState({
    this.status = ZoneDetailsStatus.initial,
    this.zone,
    this.alerts = const [],
    this.completedPriorities = const {},
    this.errorMessage,
  });

  final ZoneDetailsStatus status;
  final Zone? zone;
  final List<AdminAlert> alerts;
  final Set<String> completedPriorities;
  final String? errorMessage;

  ZoneDetailsState copyWith({
    ZoneDetailsStatus? status,
    Zone? zone,
    List<AdminAlert>? alerts,
    Set<String>? completedPriorities,
    String? errorMessage,
    bool clearZone = false,
    bool clearError = false,
  }) => ZoneDetailsState(
    status: status ?? this.status,
    zone: clearZone ? null : zone ?? this.zone,
    alerts: alerts ?? this.alerts,
    completedPriorities: completedPriorities ?? this.completedPriorities,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    status,
    zone,
    alerts,
    completedPriorities,
    errorMessage,
  ];
}

class ZoneDetailsCubit extends Cubit<ZoneDetailsState> {
  ZoneDetailsCubit(this._repository, this.zoneId)
    : super(const ZoneDetailsState()) {
    _subscription = _repository.changes.listen((_) => load());
    load();
  }

  final AdminRepository _repository;
  final String zoneId;
  late final StreamSubscription<void> _subscription;

  Zone? get zone => state.zone;
  List<AdminAlert> get alerts => state.alerts;
  Set<String> get completedPriorities => state.completedPriorities;

  void load() {
    emit(state.copyWith(status: ZoneDetailsStatus.loading));
    try {
      final zone = _repository.getZoneById(zoneId);
      emit(
        state.copyWith(
          status: ZoneDetailsStatus.success,
          zone: zone,
          alerts: List.unmodifiable(_repository.getAlertsForZone(zoneId)),
          clearZone: zone == null,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ZoneDetailsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void togglePriority(String priority) {
    final priorities = Set<String>.of(state.completedPriorities);
    if (!priorities.add(priority)) priorities.remove(priority);
    emit(state.copyWith(completedPriorities: Set.unmodifiable(priorities)));
  }

  bool isPriorityCompleted(String priority) =>
      state.completedPriorities.contains(priority);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
