import 'package:equatable/equatable.dart';

import '../models/analysis_model.dart';

enum AnalysisResultStatus { loading, success, notFound, failure }

class AnalysisResultState extends Equatable {
  const AnalysisResultState({
    required this.status,
    this.analysis,
    this.errorMessage,
  });

  final AnalysisResultStatus status;
  final Analysis? analysis;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, analysis, errorMessage];
}
