import 'package:equatable/equatable.dart';

import '../models/analysis_model.dart';
import '../models/zone_model.dart';

enum AnalysisResultStatus { loading, success, notFound, failure }

class AnalysisResultState extends Equatable {
  const AnalysisResultState({
    required this.status,
    this.analysis,
    this.zones = const [],
    this.errorMessage,
  });

  final AnalysisResultStatus status;
  final Analysis? analysis;
  final List<Zone> zones;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, analysis, zones, errorMessage];
}
