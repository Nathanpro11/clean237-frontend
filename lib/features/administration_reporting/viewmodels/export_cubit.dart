import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';

import '../../../data/exceptions/app_exception.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../data/services/report_file_service.dart';
import '../models/report_model.dart';
import 'export_state.dart';

class ExportCubit extends Cubit<ExportState> {
  ExportCubit(this._repository) : super(const ExportState());

  final AdminRepository _repository;
  final ReportFileService _fileService = const ReportFileService();

  Future<void> startExport({
    required String reportId,
    required String reportTitle,
    required ReportFormat format,
  }) async {
    if (state.isExporting) return;
    emit(
      state.copyWith(
        status: ExportStatus.loading,
        reportTitle: reportTitle,
        clearError: true,
        clearFile: true,
      ),
    );
    try {
      final bytes = await _repository.exportReport(reportId, format);
      final savedFile = await _fileService.save(
        bytes: bytes,
        title: reportTitle,
        format: format,
      );
      emit(
        state.copyWith(
          status: ExportStatus.success,
          generatedFilePath: savedFile.path,
          generatedFileName: savedFile.name,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: ExportStatus.failure,
          errorMessage: error.message,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: ExportStatus.failure,
          errorMessage:
              'Impossible d’enregistrer le fichier exporté. Veuillez réessayer.',
        ),
      );
    }
  }

  Future<void> openExportedFile() async {
    final path = state.generatedFilePath;
    if (path == null) return;
    try {
      final result = await OpenFilex.open(path);
      if (result.type != ResultType.done) {
        throw StateError(result.message);
      }
    } on Object {
      emit(
        state.copyWith(
          status: ExportStatus.failure,
          errorMessage: 'Impossible d’ouvrir le fichier exporté.',
        ),
      );
    }
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
