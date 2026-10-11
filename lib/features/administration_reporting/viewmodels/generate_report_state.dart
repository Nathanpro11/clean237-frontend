import 'package:equatable/equatable.dart';

import '../models/zone_model.dart';
import 'generate_report_event.dart';

enum SubmissionStatus { idle, submitting, success, failure }

class GenerateReportState extends Equatable {
  const GenerateReportState({
    this.title = '',
    this.selectedPeriod = 'Septembre 2026',
    this.isCustomPeriod = false,
    this.customStartDate,
    this.customEndDate,
    this.selectedZoneIds = const {},
    this.availableZones = const [],
    this.selectedFormat = ExportDocumentFormat.pdf,
    this.notes = '',
    this.titleError,
    this.zonesError,
    this.dateError,
    this.notesError,
    this.submissionStatus = SubmissionStatus.idle,
    this.errorMessage,
    this.generatedFilePath,
    this.hasSubmittedOnce = false,
  });

  final String title;
  final String selectedPeriod;
  final bool isCustomPeriod;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final Set<String> selectedZoneIds;
  final List<Zone> availableZones;
  final ExportDocumentFormat selectedFormat;
  final String notes;
  final String? titleError;
  final String? zonesError;
  final String? dateError;
  final String? notesError;
  final SubmissionStatus submissionStatus;
  final String? errorMessage;
  final String? generatedFilePath;
  final bool hasSubmittedOnce;

  GenerateReportState copyWith({
    String? title,
    String? selectedPeriod,
    bool? isCustomPeriod,
    DateTime? customStartDate,
    DateTime? customEndDate,
    Set<String>? selectedZoneIds,
    List<Zone>? availableZones,
    ExportDocumentFormat? selectedFormat,
    String? notes,
    String? titleError,
    String? zonesError,
    String? dateError,
    String? notesError,
    SubmissionStatus? submissionStatus,
    String? errorMessage,
    String? generatedFilePath,
    bool? hasSubmittedOnce,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearTitleError = false,
    bool clearZonesError = false,
    bool clearDateError = false,
    bool clearNotesError = false,
    bool clearError = false,
    bool clearFile = false,
  }) => GenerateReportState(
    title: title ?? this.title,
    selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    isCustomPeriod: isCustomPeriod ?? this.isCustomPeriod,
    customStartDate: clearStartDate
        ? null
        : customStartDate ?? this.customStartDate,
    customEndDate: clearEndDate ? null : customEndDate ?? this.customEndDate,
    selectedZoneIds: selectedZoneIds ?? this.selectedZoneIds,
    availableZones: availableZones ?? this.availableZones,
    selectedFormat: selectedFormat ?? this.selectedFormat,
    notes: notes ?? this.notes,
    titleError: clearTitleError ? null : titleError ?? this.titleError,
    zonesError: clearZonesError ? null : zonesError ?? this.zonesError,
    dateError: clearDateError ? null : dateError ?? this.dateError,
    notesError: clearNotesError ? null : notesError ?? this.notesError,
    submissionStatus: submissionStatus ?? this.submissionStatus,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    generatedFilePath: clearFile
        ? null
        : generatedFilePath ?? this.generatedFilePath,
    hasSubmittedOnce: hasSubmittedOnce ?? this.hasSubmittedOnce,
  );

  @override
  List<Object?> get props => [
    title,
    selectedPeriod,
    isCustomPeriod,
    customStartDate,
    customEndDate,
    selectedZoneIds,
    availableZones,
    selectedFormat,
    notes,
    titleError,
    zonesError,
    dateError,
    notesError,
    submissionStatus,
    errorMessage,
    generatedFilePath,
    hasSubmittedOnce,
  ];
}
