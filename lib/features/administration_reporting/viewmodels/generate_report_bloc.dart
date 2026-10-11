import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/admin_repository.dart';
import '../../../utils/constances/report_constants.dart';
import '../../../utils/validators/report_validators.dart';
import '../models/report_model.dart';
import '../models/zone_model.dart';
import 'generate_report_event.dart';
import 'generate_report_state.dart';

class _RepositoryDataChanged extends GenerateReportEvent {
  const _RepositoryDataChanged();

  @override
  List<Object?> get props => [];
}

class GenerateReportBloc
    extends Bloc<GenerateReportEvent, GenerateReportState> {
  GenerateReportBloc(this._repository, {String? preselectedZoneId})
    : super(_initialState(_repository, preselectedZoneId)) {
    on<TitleChanged>(_onTitleChanged);
    on<PeriodChanged>(_onPeriodChanged);
    on<CustomDatesChanged>(_onCustomDatesChanged);
    on<ZoneToggled>(_onZoneToggled);
    on<AllZonesSelected>(_onAllZonesSelected);
    on<ZonesCleared>(_onZonesCleared);
    on<FormatChanged>(_onFormatChanged);
    on<NotesChanged>(_onNotesChanged);
    on<SubmitPressed>(_onSubmitPressed);
    on<_RepositoryDataChanged>((event, emit) {
      emit(state.copyWith(availableZones: _repository.getZones()));
    });
    _subscription = _repository.changes.listen((_) {
      add(const _RepositoryDataChanged());
    });
  }

  final AdminRepository _repository;
  late final StreamSubscription<void> _subscription;

  static const predefinedPeriods = ReportConstants.predefinedPeriods;

  String get title => state.title;
  String? get titleError => state.titleError;
  String get selectedPeriod => state.selectedPeriod;
  bool get isCustomPeriod => state.isCustomPeriod;
  DateTime? get customStartDate => state.customStartDate;
  DateTime? get customEndDate => state.customEndDate;
  String? get dateError => state.dateError;
  Set<String> get selectedZoneIds => state.selectedZoneIds;
  String? get zonesError => state.zonesError;
  ExportDocumentFormat get selectedFormat => state.selectedFormat;
  String get notes => state.notes;
  String? get notesError => state.notesError;
  bool get isExporting => state.submissionStatus == SubmissionStatus.submitting;
  String? get errorMessage => state.errorMessage;
  String? get generatedFilePath => state.generatedFilePath;
  bool get hasSubmittedOnce => state.hasSubmittedOnce;
  List<Zone> get availableZones => state.availableZones;

  void setTitle(String value) => add(TitleChanged(value));
  void setPeriod(String value) => add(PeriodChanged(value));
  void enableCustomPeriod(bool enabled) => add(
    CustomDatesChanged(
      isCustomPeriod: enabled,
      startDate: state.customStartDate,
      endDate: state.customEndDate,
    ),
  );
  void setCustomDates(DateTime? start, DateTime? end) => add(
    CustomDatesChanged(
      isCustomPeriod: state.isCustomPeriod,
      startDate: start,
      endDate: end,
    ),
  );
  void toggleZone(String id) => add(ZoneToggled(id));
  void selectAllZones() => add(const AllZonesSelected());
  void clearZoneSelection() => add(const ZonesCleared());
  void setFormat(ExportDocumentFormat value) => add(FormatChanged(value));
  void setNotes(String value) => add(NotesChanged(value));

  static GenerateReportState _initialState(
    AdminRepository repository,
    String? preselectedZoneId,
  ) {
    final zones = repository.getZones();
    final selected = <String>{'mfoundi-centre', 'biyem-assi'};
    var title = 'Rapport mensuel d’assainissement';
    if (preselectedZoneId != null && preselectedZoneId.isNotEmpty) {
      selected.add(preselectedZoneId);
      for (final zone in zones) {
        if (zone.id == preselectedZoneId) {
          title = 'Rapport propreté · ${zone.name}';
          break;
        }
      }
    }
    return GenerateReportState(
      title: title,
      selectedZoneIds: Set.unmodifiable(selected),
      availableZones: zones,
    );
  }

  void _onTitleChanged(TitleChanged event, Emitter<GenerateReportState> emit) {
    final next = state.copyWith(
      title: event.title,
      submissionStatus: SubmissionStatus.idle,
      clearError: true,
    );
    emit(
      state.hasSubmittedOnce || state.titleError != null
          ? _validate(next)
          : next,
    );
  }

  void _onPeriodChanged(
    PeriodChanged event,
    Emitter<GenerateReportState> emit,
  ) {
    emit(
      state.copyWith(
        selectedPeriod: event.period,
        isCustomPeriod: false,
        submissionStatus: SubmissionStatus.idle,
        clearError: true,
        clearDateError: true,
      ),
    );
  }

  void _onCustomDatesChanged(
    CustomDatesChanged event,
    Emitter<GenerateReportState> emit,
  ) {
    final next = state.copyWith(
      isCustomPeriod: event.isCustomPeriod,
      customStartDate: event.startDate,
      customEndDate: event.endDate,
      submissionStatus: SubmissionStatus.idle,
      clearError: true,
      clearStartDate: event.startDate == null,
      clearEndDate: event.endDate == null,
      clearDateError: !state.hasSubmittedOnce && state.dateError == null,
    );
    emit(
      state.hasSubmittedOnce || state.dateError != null
          ? _validateDates(next)
          : next,
    );
  }

  void _onZoneToggled(ZoneToggled event, Emitter<GenerateReportState> emit) {
    final selected = Set<String>.of(state.selectedZoneIds);
    if (!selected.add(event.zoneId)) selected.remove(event.zoneId);
    final next = state.copyWith(
      selectedZoneIds: Set.unmodifiable(selected),
      submissionStatus: SubmissionStatus.idle,
      clearError: true,
    );
    emit(
      state.hasSubmittedOnce || state.zonesError != null
          ? _validateZones(next)
          : next,
    );
  }

  void _onAllZonesSelected(
    AllZonesSelected event,
    Emitter<GenerateReportState> emit,
  ) {
    final selected = Set<String>.of(state.selectedZoneIds)
      ..addAll(state.availableZones.map((zone) => zone.id));
    final next = state.copyWith(
      selectedZoneIds: Set.unmodifiable(selected),
      submissionStatus: SubmissionStatus.idle,
      clearError: true,
    );
    emit(
      state.hasSubmittedOnce || state.zonesError != null
          ? _validateZones(next)
          : next,
    );
  }

  void _onZonesCleared(ZonesCleared event, Emitter<GenerateReportState> emit) {
    final next = state.copyWith(
      selectedZoneIds: const {},
      submissionStatus: SubmissionStatus.idle,
      clearError: true,
    );
    emit(
      state.hasSubmittedOnce || state.zonesError != null
          ? _validateZones(next)
          : next,
    );
  }

  void _onFormatChanged(
    FormatChanged event,
    Emitter<GenerateReportState> emit,
  ) {
    emit(
      state.copyWith(
        selectedFormat: event.format,
        submissionStatus: SubmissionStatus.idle,
        clearError: true,
      ),
    );
  }

  void _onNotesChanged(NotesChanged event, Emitter<GenerateReportState> emit) {
    final overLimit = event.notes.length > 300;
    final next = state.copyWith(
      notes: event.notes,
      submissionStatus: SubmissionStatus.idle,
      clearError: true,
      notesError: validateReportNotes(event.notes),
      clearNotesError: !overLimit,
    );
    emit(next);
  }

  Future<void> _onSubmitPressed(
    SubmitPressed event,
    Emitter<GenerateReportState> emit,
  ) async {
    if (state.submissionStatus == SubmissionStatus.submitting) return;
    final validated = _validate(state.copyWith(hasSubmittedOnce: true));
    if (validated.titleError != null ||
        validated.zonesError != null ||
        validated.dateError != null ||
        validated.notesError != null) {
      emit(validated.copyWith(submissionStatus: SubmissionStatus.failure));
      return;
    }
    emit(
      validated.copyWith(
        submissionStatus: SubmissionStatus.submitting,
        clearError: true,
        clearFile: true,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (event.simulateFailure) {
      emit(
        state.copyWith(
          submissionStatus: SubmissionStatus.failure,
          errorMessage: 'Échec de génération du document PDF (erreur serveur).',
        ),
      );
      return;
    }

    final selectedZones = state.availableZones
        .where((zone) => state.selectedZoneIds.contains(zone.id))
        .toList();
    final report = AdminReport(
      id: 'report_${DateTime.now().millisecondsSinceEpoch}',
      title: state.title.trim(),
      type: ReportType.synthesis,
      status: ReportStatus.ready,
      date: 'Aujourd’hui',
      zoneCount: selectedZones.length,
      zoneNames: selectedZones.map((zone) => zone.name).toList(),
      summary: state.notes.trim().isNotEmpty
          ? state.notes.trim()
          : 'Rapport généré pour la période ${state.isCustomPeriod ? "personnalisée" : state.selectedPeriod}.',
    );
    _repository.addReport(report);
    final extension = switch (state.selectedFormat) {
      ExportDocumentFormat.pdf => 'pdf',
      ExportDocumentFormat.excel => 'xlsx',
      ExportDocumentFormat.csv => 'csv',
    };
    emit(
      state.copyWith(
        submissionStatus: SubmissionStatus.success,
        generatedFilePath:
            'clean237_rapport_${DateTime.now().millisecondsSinceEpoch}.$extension',
      ),
    );
  }

  GenerateReportState _validate(GenerateReportState value) =>
      _validateNotes(_validateDates(_validateZones(_validateTitle(value))));

  GenerateReportState _validateTitle(GenerateReportState value) {
    final error = validateReportTitle(value.title);
    return value.copyWith(titleError: error, clearTitleError: error == null);
  }

  GenerateReportState _validateZones(GenerateReportState value) =>
      value.copyWith(
        zonesError: validateReportZones(value.selectedZoneIds),
        clearZonesError: value.selectedZoneIds.isNotEmpty,
      );

  GenerateReportState _validateDates(GenerateReportState value) {
    final error = validateReportDates(
      isCustomPeriod: value.isCustomPeriod,
      startDate: value.customStartDate,
      endDate: value.customEndDate,
    );
    return value.copyWith(dateError: error, clearDateError: error == null);
  }

  GenerateReportState _validateNotes(GenerateReportState value) {
    final error = validateReportNotes(value.notes);
    return value.copyWith(notesError: error, clearNotesError: error == null);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
