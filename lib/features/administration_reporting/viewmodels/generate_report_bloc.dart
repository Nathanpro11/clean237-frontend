import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/exceptions/app_exception.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../data/services/report_file_service.dart';
import '../../../utils/validators/report_validators.dart';
import '../models/report_model.dart';
import 'generate_report_event.dart';
import 'generate_report_state.dart';

class GenerateReportBloc
    extends Bloc<GenerateReportEvent, GenerateReportState> {
  GenerateReportBloc(
    this._repository, {
    required String? analysisId,
    String? initialTitle,
    String initialDescription = '',
    ReportFormat? initialFormat,
  }) : super(const GenerateReportState()) {
    on<InitializeReport>(_onInitialize);
    on<TitleChanged>(_onTitleChanged);
    on<NotesChanged>(_onNotesChanged);
    on<FormatChanged>(_onFormatChanged);
    on<SubmitPressed>(_onSubmitPressed);
    add(
      InitializeReport(
        analysisId: analysisId,
        initialTitle: initialTitle,
        initialDescription: initialDescription,
        initialFormat: initialFormat,
      ),
    );
  }

  final AdminRepository _repository;
  final ReportFileService _fileService = const ReportFileService();

  void setTitle(String title) => add(TitleChanged(title));
  void setDescription(String description) => add(NotesChanged(description));
  void setFormat(ReportFormat format) => add(FormatChanged(format));

  Future<void> _onInitialize(
    InitializeReport event,
    Emitter<GenerateReportState> emit,
  ) async {
    final analysisId = event.analysisId;
    if (analysisId == null || analysisId.isEmpty) {
      emit(
        state.copyWith(
          analysisId: analysisId,
          status: ReportFormStatus.invalidAnalysis,
          clearAnalysis: true,
          errorMessage:
              'Une analyse est nécessaire pour créer un rapport.',
        ),
      );
      return;
    }
    try {
      final analysis = await _repository.getAnalysisById(analysisId);
      emit(
        GenerateReportState(
          analysisId: analysis.id,
          analysis: analysis,
          title: event.initialTitle ??
              _defaultTitle(analysis.type, analysis.createdAt),
          description: event.initialDescription,
          format: event.initialFormat == ReportFormat.csv
              ? ReportFormat.csv
              : ReportFormat.pdf,
          status: ReportFormStatus.ready,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          analysisId: analysisId,
          status: ReportFormStatus.failure,
          clearAnalysis: true,
          errorMessage: error.message,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          analysisId: analysisId,
          status: ReportFormStatus.failure,
          clearAnalysis: true,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _onTitleChanged(TitleChanged event, Emitter<GenerateReportState> emit) {
    final titleError = state.titleError == null
        ? null
        : validateReportTitle(event.title);
    emit(
      state.copyWith(
        title: event.title,
        titleError: titleError,
        clearTitleError: titleError == null,
        status: ReportFormStatus.ready,
        clearError: true,
        clearFile: true,
        clearGeneratedReport: true,
      ),
    );
  }

  void _onNotesChanged(NotesChanged event, Emitter<GenerateReportState> emit) {
    final notesError = state.descriptionError == null
        ? null
        : validateReportNotes(event.notes);
    emit(
      state.copyWith(
        description: event.notes,
        descriptionError: notesError,
        clearDescriptionError: notesError == null,
        status: ReportFormStatus.ready,
        clearError: true,
        clearFile: true,
        clearGeneratedReport: true,
      ),
    );
  }

  void _onFormatChanged(FormatChanged event, Emitter<GenerateReportState> emit) {
    emit(
      state.copyWith(
        format: event.format,
        status: ReportFormStatus.ready,
        clearError: true,
        clearFile: true,
        clearGeneratedReport: true,
      ),
    );
  }

  Future<void> _onSubmitPressed(
    SubmitPressed event,
    Emitter<GenerateReportState> emit,
  ) async {
    if (state.status == ReportFormStatus.submitting) return;
    final titleError = validateReportTitle(state.title);
    final descriptionError = validateReportNotes(state.description);
    if (titleError != null || descriptionError != null) {
      emit(
        state.copyWith(
          titleError: titleError,
          descriptionError: descriptionError,
          clearTitleError: titleError == null,
          clearDescriptionError: descriptionError == null,
          status: ReportFormStatus.failure,
          clearError: true,
        ),
      );
      return;
    }
    if (state.analysis == null || state.analysisId == null) {
      emit(
        state.copyWith(
          status: ReportFormStatus.invalidAnalysis,
          errorMessage: 'Une analyse est nécessaire pour créer un rapport.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: ReportFormStatus.submitting,
        clearError: true,
        clearFile: true,
        clearGeneratedReport: true,
        clearSuccess: true,
      ),
    );
    try {
      final reportResult = await _repository.generateReport(
        analysisId: state.analysisId!,
        title: state.title.trim(),
        description: state.description.trim().isEmpty
            ? null
            : state.description.trim(),
        format: state.format,
      );
      final report = reportResult.data;
      emit(state.copyWith(
        generatedReportId: report.id,
        successMessage: reportResult.message ?? 'Rapport généré avec succès.',
      ));
      final bytes = await _repository.exportReport(report.id, state.format);
      final savedFile = await _fileService.save(
        bytes: bytes,
        title: report.title,
        format: state.format,
      );
      emit(
        state.copyWith(
          status: ReportFormStatus.success,
          generatedFilePath: savedFile.path,
          generatedFileName: savedFile.name,
          generatedReportId: report.id,
          successMessage: reportResult.message ?? 'Rapport généré avec succès.',
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: ReportFormStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ReportFormStatus.failure,
          errorMessage:
              'Impossible d’enregistrer le fichier exporté. Veuillez réessayer.',
        ),
      );
    }
  }

  String _defaultTitle(String type, DateTime date) =>
      'Rapport · $type · ${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
