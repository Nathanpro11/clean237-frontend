import 'package:equatable/equatable.dart';

import '../models/zone_model.dart';

enum AnalysisPeriodPreset { last7Days, last30Days, currentMonth, custom }

enum AnalysisSubmissionStatus { idle, submitting, success, failure }

class AnalysisFormState extends Equatable {
  const AnalysisFormState({
    required this.zones,
    required this.selectedZoneIds,
    required this.periodStart,
    required this.periodEnd,
    this.periodPreset = AnalysisPeriodPreset.last7Days,
    this.status = AnalysisSubmissionStatus.idle,
    this.periodError,
    this.zonesError,
    this.errorMessage,
  });

  final List<Zone> zones;
  final Set<String> selectedZoneIds;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final AnalysisPeriodPreset periodPreset;
  final AnalysisSubmissionStatus status;
  final String? periodError;
  final String? zonesError;
  final String? errorMessage;

  AnalysisFormState copyWith({
    List<Zone>? zones,
    Set<String>? selectedZoneIds,
    DateTime? periodStart,
    DateTime? periodEnd,
    AnalysisPeriodPreset? periodPreset,
    AnalysisSubmissionStatus? status,
    String? periodError,
    String? zonesError,
    String? errorMessage,
    bool clearPeriodError = false,
    bool clearZonesError = false,
    bool clearError = false,
  }) => AnalysisFormState(
    zones: zones ?? this.zones,
    selectedZoneIds: selectedZoneIds ?? this.selectedZoneIds,
    periodStart: periodStart ?? this.periodStart,
    periodEnd: periodEnd ?? this.periodEnd,
    periodPreset: periodPreset ?? this.periodPreset,
    status: status ?? this.status,
    periodError: clearPeriodError ? null : periodError ?? this.periodError,
    zonesError: clearZonesError ? null : zonesError ?? this.zonesError,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    zones,
    selectedZoneIds,
    periodStart,
    periodEnd,
    periodPreset,
    status,
    periodError,
    zonesError,
    errorMessage,
  ];
}
