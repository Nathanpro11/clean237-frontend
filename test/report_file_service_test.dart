import 'dart:typed_data';

import 'package:clean237_frontend/data/services/report_file_service.dart';
import 'package:clean237_frontend/features/administration_reporting/models/report_model.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'saves PDF bytes with a safe dated name and matching MIME type',
    () async {
      String? savedName;
      String? savedExtension;
      MimeType? savedMimeType;
      Uint8List? savedBytes;

      final service = ReportFileService(
        saveFile:
            ({
              required String name,
              required Uint8List bytes,
              required String fileExtension,
              required MimeType mimeType,
            }) async {
              savedName = name;
              savedBytes = bytes;
              savedExtension = fileExtension;
              savedMimeType = mimeType;
              return 'Downloads';
            },
      );

      final savedFile = await service.save(
        bytes: [37, 80, 68, 70],
        title: 'Rapport: Zone / Test?',
        format: ReportFormat.pdf,
      );

      expect(savedName, matches(r'^rapport-rapport-zone-test-\d{8}$'));
      expect(savedFile.name, '$savedName.pdf');
      expect(savedFile.path, 'Downloads');
      expect(savedBytes, [37, 80, 68, 70]);
      expect(savedExtension, 'pdf');
      expect(savedMimeType, MimeType.pdf);

      await service.save(
        bytes: [97, 44, 98],
        title: 'Export CSV',
        format: ReportFormat.csv,
      );
      expect(savedExtension, 'csv');
      expect(savedMimeType, MimeType.csv);
    },
  );
}
