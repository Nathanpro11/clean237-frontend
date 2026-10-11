import 'package:flutter/foundation.dart';

import 'package:clean237_frontend/data/repositories/admin_repository.dart';

import '../models/report_model.dart';
import '../models/zone_model.dart';

enum ExportDocumentFormat {
  pdf('PDF (.pdf)', 'Format document officiel'),
  excel('Excel (.xlsx)', 'Données brutes et feuilles de calcul'),
  csv('CSV (.csv)', 'Export léger compatible SIG');

  final String label;
  final String description;
  const ExportDocumentFormat(this.label, this.description);
}

/// ViewModel gérant la création de rapport et la validation côté client
class GenerateReportViewModel extends ChangeNotifier {
  final AdminRepository _repository;

  String _title = '';
  String? _titleError;

  String _selectedPeriod = 'Septembre 2026';
  bool _isCustomPeriod = false;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  String? _dateError;

  final Set<String> _selectedZoneIds = {'mfoundi-centre', 'biyem-assi'};
  String? _zonesError;

  ExportDocumentFormat _selectedFormat = ExportDocumentFormat.pdf;
  String _notes = '';
  String? _notesError;

  bool _isExporting = false;
  String? _errorMessage;
  String? _generatedFilePath;
  bool _hasSubmittedOnce = false;

  final List<String> predefinedPeriods = const [
    'Septembre 2026',
    'Août 2026',
    '3e Trimestre 2026',
    'Année 2026',
  ];

  GenerateReportViewModel({
    AdminRepository? repository,
    String? preselectedZoneId,
  }) : _repository = repository ?? AdminRepository.instance {
    if (preselectedZoneId != null && preselectedZoneId.isNotEmpty) {
      _selectedZoneIds.add(preselectedZoneId);
      final zone = _repository.getZoneById(preselectedZoneId);
      if (zone != null) {
        _title = 'Rapport propreté · ${zone.name}';
      }
    } else {
      _title = 'Rapport mensuel d’assainissement';
    }
  }

  // Getters
  String get title => _title;
  String? get titleError => _titleError;
  String get selectedPeriod => _selectedPeriod;
  bool get isCustomPeriod => _isCustomPeriod;
  DateTime? get customStartDate => _customStartDate;
  DateTime? get customEndDate => _customEndDate;
  String? get dateError => _dateError;
  Set<String> get selectedZoneIds => Set.unmodifiable(_selectedZoneIds);
  String? get zonesError => _zonesError;
  ExportDocumentFormat get selectedFormat => _selectedFormat;
  String get notes => _notes;
  String? get notesError => _notesError;
  bool get isExporting => _isExporting;
  String? get errorMessage => _errorMessage;
  String? get generatedFilePath => _generatedFilePath;
  bool get hasSubmittedOnce => _hasSubmittedOnce;

  List<Zone> get availableZones => _repository.allZones;

  // Setters avec validation automatique si déjà soumis au moins une fois
  void setTitle(String val) {
    _title = val;
    if (_hasSubmittedOnce || _titleError != null) {
      validateTitle();
    } else {
      notifyListeners();
    }
  }

  void setPeriod(String period) {
    _selectedPeriod = period;
    _isCustomPeriod = false;
    _dateError = null;
    notifyListeners();
  }

  void enableCustomPeriod(bool enable) {
    _isCustomPeriod = enable;
    if (_hasSubmittedOnce) {
      validateCustomDateRange();
    } else {
      notifyListeners();
    }
  }

  void setCustomDates(DateTime? start, DateTime? end) {
    _customStartDate = start;
    _customEndDate = end;
    if (_hasSubmittedOnce || _dateError != null) {
      validateCustomDateRange();
    } else {
      notifyListeners();
    }
  }

  void toggleZone(String zoneId) {
    if (_selectedZoneIds.contains(zoneId)) {
      _selectedZoneIds.remove(zoneId);
    } else {
      _selectedZoneIds.add(zoneId);
    }

    if (_hasSubmittedOnce || _zonesError != null) {
      validateZones();
    } else {
      notifyListeners();
    }
  }

  void selectAllZones() {
    _selectedZoneIds.addAll(availableZones.map((z) => z.id));
    if (_hasSubmittedOnce || _zonesError != null) {
      validateZones();
    } else {
      notifyListeners();
    }
  }

  void clearZoneSelection() {
    _selectedZoneIds.clear();
    if (_hasSubmittedOnce || _zonesError != null) {
      validateZones();
    } else {
      notifyListeners();
    }
  }

  void setFormat(ExportDocumentFormat format) {
    _selectedFormat = format;
    notifyListeners();
  }

  void setNotes(String val) {
    _notes = val;
    if (val.length > 300) {
      _notesError =
          'Les observations ne doivent pas dépasser 300 caractères (${val.length}/300)';
    } else {
      _notesError = null;
    }
    notifyListeners();
  }

  // VALIDATIONS CÔTÉ CLIENT (Tâche 5)
  bool validateTitle() {
    final trimmed = _title.trim();
    if (trimmed.isEmpty) {
      _titleError = 'Le titre du rapport est obligatoire.';
    } else if (trimmed.length < 4) {
      _titleError = 'Le titre doit comporter au moins 4 caractères.';
    } else if (trimmed.length > 80) {
      _titleError = 'Le titre ne doit pas dépasser 80 caractères.';
    } else {
      _titleError = null;
    }
    notifyListeners();
    return _titleError == null;
  }

  bool validateZones() {
    if (_selectedZoneIds.isEmpty) {
      _zonesError = 'Veuillez sélectionner au moins une zone d’analyse.';
    } else {
      _zonesError = null;
    }
    notifyListeners();
    return _zonesError == null;
  }

  bool validateCustomDateRange() {
    if (!_isCustomPeriod) {
      _dateError = null;
      notifyListeners();
      return true;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_customStartDate == null || _customEndDate == null) {
      _dateError = 'Veuillez renseigner la date de début et la date de fin.';
    } else if (_customStartDate!.isAfter(_customEndDate!)) {
      _dateError = 'La date de début doit être antérieure à la date de fin.';
    } else if (DateTime(
      _customEndDate!.year,
      _customEndDate!.month,
      _customEndDate!.day,
    ).isAfter(today)) {
      _dateError = 'La date de fin ne peut pas être située dans le futur.';
    } else {
      _dateError = null;
    }
    notifyListeners();
    return _dateError == null;
  }

  bool validateAll() {
    _hasSubmittedOnce = true;
    final isTitleValid = validateTitle();
    final isZonesValid = validateZones();
    final isDatesValid = validateCustomDateRange();
    final isNotesValid = _notesError == null;

    notifyListeners();
    return isTitleValid && isZonesValid && isDatesValid && isNotesValid;
  }

  /// Exécution de la génération de rapport
  Future<bool> submitReport({bool simulateFailure = false}) async {
    if (!validateAll()) {
      return false;
    }

    _isExporting = true;
    _errorMessage = null;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 1400));

    if (simulateFailure) {
      _isExporting = false;
      _errorMessage = 'Échec de génération du document PDF (erreur serveur).';
      notifyListeners();
      return false;
    }

    final selectedZoneObjects = availableZones
        .where((z) => _selectedZoneIds.contains(z.id))
        .toList();

    final newReport = AdminReport(
      id: 'report_${DateTime.now().millisecondsSinceEpoch}',
      title: _title.trim(),
      type: ReportType.synthesis,
      status: ReportStatus.ready,
      date: 'Aujourd’hui',
      zoneCount: selectedZoneObjects.length,
      zoneNames: selectedZoneObjects.map((z) => z.name).toList(),
      summary: _notes.trim().isNotEmpty
          ? _notes.trim()
          : 'Rapport généré pour la période ${_isCustomPeriod ? "personnalisée" : _selectedPeriod}.',
    );

    _repository.addReport(newReport);

    final ext = switch (_selectedFormat) {
      ExportDocumentFormat.pdf => 'pdf',
      ExportDocumentFormat.excel => 'xlsx',
      ExportDocumentFormat.csv => 'csv',
    };

    _generatedFilePath =
        'clean237_rapport_${DateTime.now().millisecondsSinceEpoch}.$ext';
    _isExporting = false;
    notifyListeners();
    return true;
  }
}
