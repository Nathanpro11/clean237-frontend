import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/admin_repository.dart';
import '../../../utils/validators/report_validators.dart';
import '../models/analysis_model.dart';
import 'analysis_form_state.dart';

class AnalysisFormCubit extends Cubit<AnalysisFormState> {
  AnalysisFormCubit(this._repository, {String? preselectedZoneId})
    : super(_initialState(_repository, preselectedZoneId));

  final AdminRepository _repository;

  static AnalysisFormState _initialState(
    AdminRepository repository,
    String? preselectedZoneId,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final zones = repository.getZones();
    final preselectedIsKnown = zones.any(
      (zone) => zone.id == preselectedZoneId,
    );
    return AnalysisFormState(
      zones: zones,
      selectedZoneIds: preselectedIsKnown
          ? Set.unmodifiable({preselectedZoneId!})
          : const {},
      periodStart: today.subtract(const Duration(days: 6)),
      periodEnd: today,
      errorMessage:
          preselectedZoneId != null && !preselectedIsKnown
              ? 'La zone demandée est introuvable.'
              : null,
    );
  }

  void toggleZone(String zoneId) {
    final selected = Set<String>.of(state.selectedZoneIds);
    if (!selected.add(zoneId)) selected.remove(zoneId);
    emit(
      state.copyWith(
        selectedZoneIds: Set.unmodifiable(selected),
        status: AnalysisSubmissionStatus.idle,
        clearZonesError: true,
        clearError: true,
      ),
    );
  }

  void selectPeriodPreset(AnalysisPeriodPreset preset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final (start, end) = switch (preset) {
      AnalysisPeriodPreset.last7Days => (
        today.subtract(const Duration(days: 6)),
        today,
      ),
      AnalysisPeriodPreset.last30Days => (
        today.subtract(const Duration(days: 29)),
        today,
      ),
      AnalysisPeriodPreset.currentMonth => (
        DateTime(today.year, today.month),
        today,
      ),
      AnalysisPeriodPreset.custom => (state.periodStart, state.periodEnd),
    };
    emit(
      state.copyWith(
        periodPreset: preset,
        periodStart: start,
        periodEnd: end,
        status: AnalysisSubmissionStatus.idle,
        clearPeriodError: true,
        clearError: true,
      ),
    );
  }

  void setCustomPeriod({DateTime? start, DateTime? end}) {
    emit(
      state.copyWith(
        periodPreset: AnalysisPeriodPreset.custom,
        periodStart: start,
        periodEnd: end,
        status: AnalysisSubmissionStatus.idle,
        clearPeriodError: true,
        clearError: true,
      ),
    );
  }

  Future<Analysis?> generateAnalysis() async {
    final periodError = validateAnalysisPeriod(
      startDate: state.periodStart,
      endDate: state.periodEnd,
    );
    final zonesError = validateAnalysisZones(state.selectedZoneIds);
    if (periodError != null || zonesError != null) {
      emit(
        state.copyWith(
          status: AnalysisSubmissionStatus.failure,
          periodError: periodError,
          zonesError: zonesError,
          clearPeriodError: periodError == null,
          clearZonesError: zonesError == null,
          clearError: true,
        ),
      );
      return null;
    }

    emit(
      state.copyWith(
        status: AnalysisSubmissionStatus.submitting,
        clearPeriodError: true,
        clearZonesError: true,
        clearError: true,
      ),
    );
    try {
      final analysis = _repository.generateAnalysis(
        periodStart: state.periodStart,
        periodEnd: state.periodEnd,
        zoneIds: state.selectedZoneIds.toList(),
      );
      emit(state.copyWith(status: AnalysisSubmissionStatus.success));
      return analysis;
    } on AdminRepositoryException catch (error) {
      emit(
        state.copyWith(
          status: AnalysisSubmissionStatus.failure,
          errorMessage: error.message,
        ),
      );
      return null;
    }
  }
}
