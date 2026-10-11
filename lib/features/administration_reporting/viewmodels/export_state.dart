import 'package:equatable/equatable.dart';

enum ExportStatus { initial, loading, success, failure }

class ExportState extends Equatable {
  const ExportState({
    this.status = ExportStatus.initial,
    this.errorMessage,
    this.generatedFilePath,
    this.reportTitle,
  });

  final ExportStatus status;
  final String? errorMessage;
  final String? generatedFilePath;
  final String? reportTitle;

  bool get isExporting => status == ExportStatus.loading;

  ExportState copyWith({
    ExportStatus? status,
    String? errorMessage,
    String? generatedFilePath,
    String? reportTitle,
    bool clearError = false,
    bool clearFile = false,
  }) => ExportState(
    status: status ?? this.status,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    generatedFilePath: clearFile
        ? null
        : generatedFilePath ?? this.generatedFilePath,
    reportTitle: reportTitle ?? this.reportTitle,
  );

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    generatedFilePath,
    reportTitle,
  ];
}
