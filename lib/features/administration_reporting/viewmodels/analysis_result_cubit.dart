import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/exceptions/app_exception.dart';
import '../../../data/repositories/admin_repository.dart';
import 'analysis_result_state.dart';

class AnalysisResultCubit extends Cubit<AnalysisResultState> {
  AnalysisResultCubit(this._repository, this.analysisId)
    : super(const AnalysisResultState(status: AnalysisResultStatus.loading)) {
    load();
  }

  final AdminRepository _repository;
  final String analysisId;

  Future<void> load() async {
    emit(
      const AnalysisResultState(status: AnalysisResultStatus.loading),
    );
    try {
      final analysis = await _repository.getAnalysisById(analysisId);
      emit(
        AnalysisResultState(
          status: AnalysisResultStatus.success,
          analysis: analysis,
        ),
      );
    } on NotFoundException {
      emit(const AnalysisResultState(status: AnalysisResultStatus.notFound));
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
