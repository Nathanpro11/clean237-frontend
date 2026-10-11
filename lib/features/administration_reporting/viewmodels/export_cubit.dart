import 'package:flutter_bloc/flutter_bloc.dart';

import 'export_state.dart';

class ExportCubit extends Cubit<ExportState> {
  ExportCubit() : super(const ExportState());

  Future<void> startExport({
    required String reportTitle,
    bool simulateFailure = false,
    Duration delay = const Duration(milliseconds: 1400),
  }) async {
    if (state.isExporting) return;
    emit(
      state.copyWith(
        status: ExportStatus.loading,
        reportTitle: reportTitle,
        clearError: true,
      ),
    );
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (simulateFailure) {
      emit(
        state.copyWith(
          status: ExportStatus.failure,
          errorMessage:
              'Une erreur réseau ou de génération du document PDF est survenue.',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: ExportStatus.success,
        generatedFilePath:
            'clean237_rapport_${DateTime.now().millisecondsSinceEpoch}.pdf',
      ),
    );
  }

  void reset() {
    emit(
      const ExportState().copyWith(
        status: ExportStatus.initial,
        clearError: true,
        clearFile: true,
      ),
    );
  }
}
