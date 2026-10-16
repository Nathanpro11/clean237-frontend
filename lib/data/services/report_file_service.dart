import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';

import '../exceptions/app_exception.dart';
import '../../features/administration_reporting/models/report_model.dart';

typedef ReportFileSave = Future<String> Function({
  required String name,
  required Uint8List bytes,
  required String fileExtension,
  required MimeType mimeType,
});

class SavedReportFile {
  const SavedReportFile({required this.name, this.path});

  final String name;
  final String? path;
}

class ReportFileService {
  const ReportFileService({this.saveFile});

  final ReportFileSave? saveFile;

  Future<SavedReportFile> save({
    required List<int> bytes,
    required String title,
    required ReportFormat format,
  }) async {
    if (format == ReportFormat.excel) {
      throw const ValidationException(
        'Le format Excel sera bientôt disponible.',
      );
    }
    if (bytes.isEmpty) {
      throw const ValidationException(
        'Le serveur a retourné un fichier vide. Veuillez réessayer.',
      );
    }

    final extension = format == ReportFormat.csv ? 'csv' : 'pdf';
    final name = _buildFileName(title);
    final save = saveFile ?? _saveWithFileSaver;
    final path = await save(
      name: name,
      bytes: Uint8List.fromList(bytes),
      fileExtension: extension,
      mimeType: format == ReportFormat.csv ? MimeType.csv : MimeType.pdf,
    );
    return SavedReportFile(name: '$name.$extension', path: path);
  }

  String _buildFileName(String title) {
    final slug = title
        .toLowerCase()
        .replaceAll(RegExp(r'[\u0000-\u001f<>:"/\\|?*]'), ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^[-.]+|[-.]+$'), '');
    final date = DateTime.now();
    final dateStamp =
        '${date.year.toString().padLeft(4, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
    return 'rapport-${slug.isEmpty ? 'sans-titre' : slug}-$dateStamp';
  }

  Future<String> _saveWithFileSaver({
    required String name,
    required Uint8List bytes,
    required String fileExtension,
    required MimeType mimeType,
  }) => FileSaver.instance.saveFile(
    name: name,
    bytes: bytes,
    fileExtension: fileExtension,
    mimeType: mimeType,
  );
}
