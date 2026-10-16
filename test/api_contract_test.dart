import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:clean237_frontend/data/dto/alert_dto.dart';
import 'package:clean237_frontend/data/dto/analysis_dto.dart';
import 'package:clean237_frontend/data/dto/dashboard_dto.dart';
import 'package:clean237_frontend/data/dto/pagination_dto.dart';
import 'package:clean237_frontend/data/dto/problematic_zone_dto.dart';
import 'package:clean237_frontend/data/dto/report_dto.dart';
import 'package:clean237_frontend/data/dto/zone_details_dto.dart';
import 'package:clean237_frontend/data/mappers/alert_mapper.dart';
import 'package:clean237_frontend/data/mappers/analysis_mapper.dart';
import 'package:clean237_frontend/data/mappers/report_mapper.dart';
import 'package:clean237_frontend/data/mappers/zone_mapper.dart';
import 'package:clean237_frontend/data/repositories/admin_repository.dart';
import 'package:clean237_frontend/data/services/admin_mock_data_source.dart';
import 'package:clean237_frontend/data/services/report_file_service.dart';
import 'package:clean237_frontend/features/administration_reporting/models/alert_model.dart';
import 'package:clean237_frontend/features/administration_reporting/models/report_model.dart';
import 'package:clean237_frontend/features/administration_reporting/models/zone_model.dart';
import 'package:clean237_frontend/features/administration_reporting/viewmodels/analysis_form_cubit.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('v3 route fixtures deserialize', () {
    test('dashboard and problematic-zone routes', () {
      final dashboard = DashboardDto.fromJson(fixture('dashboard'));
      expect(dashboard.totalZones, 4);
      expect(dashboard.alertesActives, 5);
      expect(dashboard.dataByType['air'], 7);

      final zoneJson = fixture('problematic_zones')['zones'] as List;
      expect(
        zoneJson.map((json) => ProblematicZoneDto.fromJson(json)).single.nom,
        'Mfoundi Centre',
      );
      final detail = ZoneDetailsDto.fromJson(
        fixture('zone_details')['zone'] as Map<String, dynamic>,
      );
      expect(detail.evolution30Jours, hasLength(3));
      expect(detail.priorites, ['Priorité issue de la zone']);
    });

    test('alert list, details, and treated routes', () {
      final list = fixture('alert_list');
      final alerts = (list['data'] as List)
          .map((json) => AlertDto.fromJson(json))
          .toList();
      expect(alerts, hasLength(2));
      expect(PaginationDto.fromJson(list['pagination']).total, 2);
      expect(
        AlertDto.fromJson(fixture('alert_detail')['alerte']).severite,
        'avertissement',
      );
      expect(
        AlertDto.fromJson(fixture('alert_treated')['alerte']).statut,
        'traitee',
      );
    });

    test('analysis generate and detail routes', () {
      final generated = AnalysisDto.fromJson(
        fixture('analysis_generated')['analyse'],
      );
      expect(generated.id, '64b000000000000000000021');
      expect(generated.indicateurs.parType['air']?.count, 2);
      final analysis = const AnalysisMapper().fromDto(generated);
      expect(analysis.indicators.byType['air']?.average, 12.5);
      expect(analysis.zoneName, 'Mfoundi Centre');
      expect(
        AnalysisDto.fromJson(fixture('analysis_detail')['analyse'])
            .indicateurs
            .totalPoints,
        0,
      );
    });

    test('report generate, list, detail, status, delete, export fixtures', () {
      expect(
        ReportDto.fromJson(fixture('report_generated')['report']).format,
        'pdf',
      );
      final reports = fixture('reports_list');
      expect(
        (reports['data'] as List).map(
          (json) => ReportDto.fromJson(Map<String, dynamic>.from(json as Map)),
        ),
        hasLength(1),
      );
      expect(
        ReportDto.fromJson(fixture('report_detail')['report']).analysisId,
        '64b000000000000000000021',
      );
      expect(
        ReportDto.fromJson(fixture('report_status')['report']).statut,
        'archive',
      );
      expect(fixture('report_deleted'), isEmpty);
      expect(base64Decode(fixture('report_export')['base64']), isNotEmpty);
    });
  });

  group('v3 field mapping', () {
    test('health score, level, and evolution convert from severity', () {
      const mapper = ZoneMapper();
      final details = ZoneDetailsDto.fromJson(
        fixture('zone_details')['zone'] as Map<String, dynamic>,
      );
      final zone = mapper.fromDetails(details);
      expect(zone.score, 27);
      expect(zone.severityScore, 27);
      expect(zone.status, ZoneStatus.critical);
      expect(zone.evolutionPoints, 4);
      expect(zone.evolution30Days, [31, 29, 27]);
      expect(ZoneMapper.mapLevel('problématique'), ZoneStatus.warning);
      expect(ZoneMapper.mapLevel('à surveiller'), ZoneStatus.warning);
      expect(ZoneMapper.mapLevel('normal'), ZoneStatus.normal);
    });

    test('alert severity and report status map to existing enums', () {
      const alertMapper = AlertMapper();
      expect(
        alertMapper
            .fromDto(AlertDto.fromJson(fixture('alert_detail')['alerte']))
            .severity,
        AlertSeverity.warning,
      );
      expect(
        alertMapper
            .fromDto(AlertDto.fromJson(fixture('alert_treated')['alerte']))
            .status,
        AlertStatus.treated,
      );
      expect(ReportMapper.mapStatus('pret'), ReportStatus.ready);
      expect(ReportMapper.mapStatus('en_cours'), ReportStatus.inProgress);
      expect(ReportMapper.mapStatus('archive'), ReportStatus.archived);
    });

    test('analysisId accepts an id string or a populated analysis object', () {
      final stringReport = ReportDto.fromJson(
        fixture('report_generated')['report'],
      );
      final populatedReport = ReportDto.fromJson(
        fixture('report_detail')['report'],
      );
      expect(stringReport.analysisId, '64b000000000000000000021');
      expect(populatedReport.analysisId, '64b000000000000000000021');
      expect(
        const ReportMapper().fromDto(populatedReport).analysisId,
        '64b000000000000000000021',
      );
    });

    test('optional report and zone fields remain absent', () {
      final minimalReport = ReportDto.fromJson({
        '_id': '64b000000000000000000031',
        'titre': 'Rapport',
        'type': 'synthese',
        'statut': 'pret',
        'format': 'pdf',
        'zones': [],
        'analyseId': null,
        'statistiques': {},
        'createdAt': '2026-05-01T11:05:00.000Z',
      });
      expect(minimalReport.description, isNull);
      expect(minimalReport.updatedAt, minimalReport.createdAt);
      expect(minimalReport.analysisId, isNull);

      final minimalZone = ZoneDetailsDto.fromJson({
        '_id': '64b000000000000000000001',
        'nom': 'Zone',
        'score': 50,
        'niveau': 'normal',
        'evolution30Jours': [],
        'alertCount': 0,
        'dataCount': 0,
      });
      expect(minimalZone.derniereMiseAJour, isNull);
      expect(minimalZone.interpretation, isNull);
      expect(minimalZone.priorites, isEmpty);
    });
  });

  test(
    'mock data source completes the analysis-to-report route flow',
    () async {
      final repository = AdminRepository(dataSource: AdminMockDataSource());
      final dashboard = await repository.getDashboard();
      expect(dashboard.totalZones, greaterThan(0));

      final zones = await repository.getProblematicZones();
      final zone = zones.first;
      final details = await repository.getZoneDetails(zone.id);
      expect(details.id, zone.id);

      final now = DateTime.now();
      final analysis = await repository.generateAnalysis(
        periodStart: DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 6)),
        periodEnd: DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
        zoneId: zone.id,
      );
      expect(analysis.data.indicators.totalPoints, greaterThan(0));
      final report = await repository.generateReport(
        analysisId: analysis.data.id,
        title: 'Rapport de test',
        format: ReportFormat.csv,
      );
      expect(report.data.analysisId, analysis.data.id);
      expect(
        await repository.exportReport(report.data.id, ReportFormat.csv),
        isNotEmpty,
      );
      final archived = await repository.updateReportStatus(
        report.data.id,
        ReportStatus.archived,
      );
      expect(archived.data.status, ReportStatus.archived);
      await repository.deleteReport(report.data.id);
      await expectLater(
        repository.getReportById(report.data.id),
        throwsA(isA<Exception>()),
      );

      final activeAlerts = await repository.getAlerts(
        status: 'active',
        limit: 3,
      );
      expect(activeAlerts.items, isNotEmpty);
      final treated = await repository.treatAlert(activeAlerts.items.first.id);
      expect(treated.data.status, AlertStatus.treated);
    },
  );

  test('analysis form includes measurements from the selected end date', () async {
    final repository = AdminRepository(dataSource: AdminMockDataSource());
    final form = AnalysisFormCubit(
      repository,
      preselectedZoneId: '66d5f1a2c2b8d61c5e8e0001',
    );
    try {
      final analysis = await form.generateAnalysis();
      expect(analysis, isNotNull);
      expect(analysis!.indicators.totalPoints, greaterThan(0));
    } finally {
      await form.close();
    }
  });

  test('report export saves bytes with a safe dated name and matching MIME type',
      () async {
    String? savedName;
    String? savedExtension;
    MimeType? savedMimeType;
    Uint8List? savedBytes;

    final service = ReportFileService(
      saveFile: ({
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
  });
}
