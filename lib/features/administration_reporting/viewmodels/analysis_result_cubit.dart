import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/admin_repository.dart';
import '../models/zone_model.dart';
import 'analysis_result_state.dart';

class AnalysisResultCubit extends Cubit<AnalysisResultState> {
  AnalysisResultCubit(this._repository, this.analysisId)
    : super(const AnalysisResultState(status: AnalysisResultStatus.loading)) {
    load();
  }

  final AdminRepository _repository;
  final String analysisId;

  void load() {
    try {
      final analysis = _repository.getAnalysisById(analysisId);
      if (analysis == null) {
        emit(const AnalysisResultState(status: AnalysisResultStatus.notFound));
        return;
      }
      final zones = analysis.zoneIds
          .map(_repository.getZoneById)
          .whereType<Zone>()
          .toList(growable: false);
      emit(
        AnalysisResultState(
          status: AnalysisResultStatus.success,
          analysis: analysis,
          zones: List.unmodifiable(zones),
        ),
      );
    } on Object catch (error) {
      emit(
        AnalysisResultState(
          status: AnalysisResultStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
