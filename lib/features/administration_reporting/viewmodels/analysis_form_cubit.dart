import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/exceptions/app_exception.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../utils/validators/report_validators.dart';
import '../models/analysis_model.dart';
import 'analysis_form_state.dart';

class AnalysisFormCubit extends Cubit<AnalysisFormState> {
  AnalysisFormCubit(this._repository, {String? preselectedZoneId})
    : super(_initialState(preselectedZoneId)) {
    loadZones();
  }

  final AdminRepository _repository;

  static AnalysisFormState _initialState(String? preselectedZoneId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return AnalysisFormState(
      zones: const [],
      selectedZoneIds: preselectedZoneId == null
          ? const {}
          : Set.unmodifiable({preselectedZoneId}),
      periodStart: today.subtract(const Duration(days: 6)),
      periodEnd: today,
    );
  }

  Future<void> loadZones() async {
    emit(state.copyWith(zonesLoading: true, clearZonesLoadError: true));
    try {
      final zones = await _repository.getProblematicZones();
      emit(
        state.copyWith(
          zones: List.unmodifiable(zones),
          zonesLoading: false,
          clearZonesLoadError: true,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(zonesLoading: false, zonesLoadError: error.message),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(zonesLoading: false, zonesLoadError: error.toString()),
      );
    }
  }

  void toggleZone(String zoneId) {
    final selected = state.selectedZoneIds.contains(zoneId)
        ? <String>{}
        : <String>{zoneId};
    emit(
      state.copyWith(
        selectedZoneIds: Set.unmodifiable(selected),
        status: AnalysisSubmissionStatus.idle,
        clearZonesError: true,
        clearError: true,
      ),
    );
  }

  void selectAllZones() {
    emit(
      state.copyWith(
        selectedZoneIds: const {},
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
    if (periodError != null) {
      emit(
        state.copyWith(
          status: AnalysisSubmissionStatus.failure,
          periodError: periodError,
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
        clearSuccess: true,
      ),
    );
    try {
      final result = await _repository.generateAnalysis(
        periodStart: state.periodStart!,
        periodEnd: _inclusiveEndOfDay(state.periodEnd!),
        zoneId: state.selectedZoneIds.isEmpty
            ? null
            : state.selectedZoneIds.single,
      );
      emit(
        state.copyWith(
          status: AnalysisSubmissionStatus.success,
          successMessage: result.message ?? 'Analyse générée avec succès.',
          clearError: true,
        ),
      );
      return result.data;
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: AnalysisSubmissionStatus.failure,
          errorMessage: error.message,
        ),
      );
      return null;
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: AnalysisSubmissionStatus.failure,
          errorMessage: error.toString(),
        ),
      );
      return null;
    }
  }

  DateTime _inclusiveEndOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
}
