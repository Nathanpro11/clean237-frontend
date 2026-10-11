import 'package:equatable/equatable.dart';

import '../models/report_model.dart';

abstract class GenerateReportEvent extends Equatable {
  const GenerateReportEvent();
}

class InitializeReport extends GenerateReportEvent {
  const InitializeReport({
    required this.analysisId,
    this.initialTitle,
    this.initialDescription = '',
    this.initialFormat,
  });

  final String? analysisId;
  final String? initialTitle;
  final String initialDescription;
  final ReportFormat? initialFormat;

  @override
  List<Object?> get props => [
    analysisId,
    initialTitle,
    initialDescription,
    initialFormat,
  ];
}

class TitleChanged extends GenerateReportEvent {
  const TitleChanged(this.title);

  final String title;

  @override
  List<Object?> get props => [title];
}

class NotesChanged extends GenerateReportEvent {
  const NotesChanged(this.notes);

  final String notes;

  @override
  List<Object?> get props => [notes];
}

class FormatChanged extends GenerateReportEvent {
  const FormatChanged(this.format);

  final ReportFormat format;

  @override
  List<Object?> get props => [format];
}

class SubmitPressed extends GenerateReportEvent {
  const SubmitPressed({this.simulateFailure = false});

  final bool simulateFailure;

  @override
  List<Object?> get props => [simulateFailure];
}
