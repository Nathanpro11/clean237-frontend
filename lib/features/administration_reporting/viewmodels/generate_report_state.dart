import 'package:equatable/equatable.dart';

import '../models/analysis_model.dart';
import '../models/report_model.dart';

enum ReportFormStatus {
  initial,
  ready,
  invalidAnalysis,
  submitting,
  success,
  failure,
}

class GenerateReportState extends Equatable {
  const GenerateReportState({
    this.analysisId,
    this.analysis,
    this.title = '',
    this.description = '',
    this.format = ReportFormat.pdf,
    this.titleError,
    this.descriptionError,
    this.status = ReportFormStatus.initial,
    this.errorMessage,
    this.successMessage,
    this.generatedFilePath,
    this.generatedFileName,
    this.generatedReportId,
  });

  final String? analysisId;
  final Analysis? analysis;
  final String title;
  final String description;
  final ReportFormat format;
  final String? titleError;
  final String? descriptionError;
  final ReportFormStatus status;
  final String? errorMessage;
  final String? successMessage;
  final String? generatedFilePath;
  final String? generatedFileName;
  final String? generatedReportId;

  GenerateReportState copyWith({
    String? analysisId,
    Analysis? analysis,
    String? title,
    String? description,
    ReportFormat? format,
    String? titleError,
    String? descriptionError,
    ReportFormStatus? status,
    String? errorMessage,
    String? successMessage,
    String? generatedFilePath,
    String? generatedFileName,
    String? generatedReportId,
    bool clearAnalysis = false,
    bool clearTitleError = false,
    bool clearDescriptionError = false,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearFile = false,
    bool clearGeneratedReport = false,
  }) => GenerateReportState(
    analysisId: analysisId ?? this.analysisId,
    analysis: clearAnalysis ? null : analysis ?? this.analysis,
    title: title ?? this.title,
    description: description ?? this.description,
    format: format ?? this.format,
    titleError: clearTitleError ? null : titleError ?? this.titleError,
    descriptionError: clearDescriptionError
        ? null
        : descriptionError ?? this.descriptionError,
    status: status ?? this.status,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    successMessage: clearSuccess ? null : successMessage ?? this.successMessage,
    generatedFilePath: clearFile
        ? null
        : generatedFilePath ?? this.generatedFilePath,
    generatedFileName: clearFile
        ? null
        : generatedFileName ?? this.generatedFileName,
    generatedReportId: clearGeneratedReport
        ? null
        : generatedReportId ?? this.generatedReportId,
  );

  @override
  List<Object?> get props => [
    analysisId,
    analysis,
    title,
    description,
    format,
    titleError,
    descriptionError,
    status,
    errorMessage,
    successMessage,
    generatedFilePath,
    generatedFileName,
    generatedReportId,
  ];
}
