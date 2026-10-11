import 'package:flutter/foundation.dart';

enum ExportStatus { idle, exporting, success, failure }

class AdminExportController extends ChangeNotifier {
  ExportStatus _status = ExportStatus.idle;
  String? _errorMessage;
  String? _generatedFilePath;
  String? _reportTitle;

  ExportStatus get status => _status;
  bool get isExporting => _status == ExportStatus.exporting;
  String? get errorMessage => _errorMessage;
  String? get generatedFilePath => _generatedFilePath;
  String? get reportTitle => _reportTitle;

  Future<bool> startExport({
    required String reportTitle,
    bool simulateFailure = false,
    Duration delay = const Duration(milliseconds: 1400),
  }) async {
    if (_status == ExportStatus.exporting) return false;

    _status = ExportStatus.exporting;
    _errorMessage = null;
    _reportTitle = reportTitle;
    notifyListeners();

    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    if (simulateFailure) {
      _status = ExportStatus.failure;
      _errorMessage =
          'Une erreur réseau ou de génération du document PDF est survenue.';
      notifyListeners();
      return false;
    } else {
      _status = ExportStatus.success;
      _generatedFilePath =
          'clean237_rapport_${DateTime.now().millisecondsSinceEpoch}.pdf';
      notifyListeners();
      return true;
    }
  }

  void reset() {
    _status = ExportStatus.idle;
    _errorMessage = null;
    _generatedFilePath = null;
    notifyListeners();
  }
}
