import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clean237_frontend/main.dart';
import 'package:clean237_frontend/common/widgets/filter_chip_group.dart';
import 'package:clean237_frontend/data/repositories/admin_repository.dart';
import 'package:clean237_frontend/features/administration_reporting/screen/admin_generate_report_page.dart';
import 'package:clean237_frontend/features/administration_reporting/screen/admin_zone_details_page.dart';
import 'package:clean237_frontend/features/administration_reporting/screen/admin_zone_analysis_page.dart';
import 'package:clean237_frontend/features/administration_reporting/models/report_model.dart';
import 'package:clean237_frontend/features/administration_reporting/screen/admin_analysis_result_page.dart';
import 'package:clean237_frontend/features/administration_reporting/screen/admin_new_analysis_page.dart';
import 'package:clean237_frontend/features/administration_reporting/viewmodels/export_cubit.dart';
import 'package:clean237_frontend/features/administration_reporting/viewmodels/export_state.dart';
import 'package:clean237_frontend/features/administration_reporting/viewmodels/analysis_form_cubit.dart';
import 'package:clean237_frontend/features/administration_reporting/viewmodels/analysis_result_cubit.dart';
import 'package:clean237_frontend/features/administration_reporting/viewmodels/analysis_result_state.dart';
import 'package:clean237_frontend/features/administration_reporting/viewmodels/generate_report_bloc.dart';
import 'package:clean237_frontend/features/administration_reporting/viewmodels/generate_report_event.dart';
import 'package:clean237_frontend/features/administration_reporting/viewmodels/generate_report_state.dart';

void main() {
  testWidgets(
    'Clean237 Admin Dashboard loads metrics and zones without overflow',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const Clean237App());
      await tester.pumpAndSettle();

      // Verify header
      expect(find.text('Clean237 · Administration'), findsWidgets);
      expect(find.text('Tableau de bord'), findsOneWidget);

      // Verify 4 metrics
      expect(find.text('Zones actives'), findsOneWidget);
      expect(find.text('Critiques'), findsOneWidget);
      expect(find.text('Alertes'), findsOneWidget);
      expect(find.text('Rapports du mois'), findsOneWidget);

      // Verify Zones à surveiller
      expect(find.text('Zones à surveiller'), findsOneWidget);
      expect(find.text('Mfoundi Centre'), findsOneWidget);
      expect(find.text('Biyem-Assi'), findsOneWidget);

      // Verify Navigation bar tabs
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Zones'), findsOneWidget);
      expect(find.text('Rapports'), findsOneWidget);
    },
  );

  testWidgets('Navigation to Zones and filtering', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const Clean237App());
    await tester.pumpAndSettle();

    // Tap on Zones navigation tab
    await tester.tap(find.text('Zones'));
    await tester.pumpAndSettle();

    // Verify search and filters
    expect(find.text('Rechercher une zone'), findsOneWidget);
    expect(find.text('Toutes'), findsOneWidget);
    expect(find.text('Normal'), findsWidgets);
    expect(find.text('À surveiller'), findsWidgets);
    expect(find.text('Critique'), findsWidgets);

    // Filter by 'Normal' chip (already visible)
    final normalFilter = find.descendant(
      of: find.byType(FilterChipGroup),
      matching: find.text('Normal'),
    );
    await tester.tap(normalFilter);
    await tester.pumpAndSettle();

    expect(find.text('Bastos'), findsOneWidget);
  });

  testWidgets('Navigation to Zone details and Analysis page', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const Clean237App());
    await tester.pumpAndSettle();

    // Tap on Mfoundi Centre card on dashboard
    await tester.tap(find.text('Mfoundi Centre'));
    await tester.pumpAndSettle();

    // Verify Zone Details
    expect(find.text('Évolution · 30 jours'), findsOneWidget);
    expect(find.text('Générer une Analyse'), findsOneWidget);

    // Tap on Générer une Analyse
    await tester.tap(find.text('Générer une Analyse'));
    await tester.pumpAndSettle();

    // Verify Analysis Page
    expect(find.text('Analyse approfondie'), findsOneWidget);
    expect(find.text('Diagnostic & Interprétation'), findsOneWidget);
    expect(find.text('Générer un rapport pour cette zone'), findsOneWidget);
  });

  test('ExportCubit handles export flow', () async {
    final cubit = ExportCubit();
    expect(cubit.state.status, ExportStatus.initial);
    expect(cubit.state.isExporting, false);

    await cubit.startExport(reportTitle: 'Test Report', delay: Duration.zero);
    expect(cubit.state.status, ExportStatus.success);
    expect(cubit.state.generatedFilePath, isNotNull);
    await cubit.close();
  });

  test('GenerateReportBloc validates and persists a report', () async {
    final repository = AdminRepository();
    final bloc = GenerateReportBloc(repository);
    try {
      final validation = bloc.stream.firstWhere(
        (state) => state.notesError != null,
      );
      bloc.add(NotesChanged('x' * 301));
      expect(
        (await validation.timeout(
          const Duration(seconds: 3),
          onTimeout: () => throw StateError('NotesChanged non émis'),
        )).notesError,
        isNotNull,
      );

      final invalidSubmission = bloc.stream.firstWhere(
        (state) => state.submissionStatus == SubmissionStatus.failure,
      );
      bloc.add(const SubmitPressed());
      await invalidSubmission.timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw StateError('SubmitPressed invalide non émis'),
      );
      expect(repository.getReports(), hasLength(4));

      final notesCleared = bloc.stream.firstWhere(
        (state) => state.notesError == null && state.notes.isEmpty,
      );
      bloc.add(const NotesChanged(''));
      await notesCleared.timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw StateError('NotesChanged valide non émis'),
      );

      final successfulSubmission = bloc.stream.firstWhere(
        (state) => state.submissionStatus == SubmissionStatus.success,
      );
      bloc.add(const SubmitPressed());
      final result = await successfulSubmission.timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw StateError('Soumission valide non terminée'),
      );
      expect(result.generatedFilePath, endsWith('.pdf'));
      expect(repository.getReports(), hasLength(5));
    } finally {
      await bloc.close();
      repository.dispose();
    }
  });

  testWidgets('AdminRepository handles data updates', (
    WidgetTester tester,
  ) async {
    final repo = AdminRepository();
    expect(repo.allZones.length, 12);
    expect(repo.criticalZones.length, 2);
    expect(repo.allAlerts.length, 7);
    repo.dispose();
  });

  test(
    'Analysis metrics are derived from selected zones and required for reports',
    () {
      final repository = AdminRepository();
      final start = DateTime(2026, 10, 1);
      final end = DateTime(2026, 10, 7);
      try {
        final analysis = repository.generateAnalysis(
          periodStart: start,
          periodEnd: end,
          zoneIds: ['mfoundi-centre', 'biyem-assi'],
        );
        expect(analysis.indicators.totalPoints, 2);
        expect(analysis.indicators.sum, 103);
        expect(analysis.indicators.average, 51.5);
        expect(analysis.indicators.minimum, 42);
        expect(analysis.indicators.maximum, 61);
        expect(analysis.indicators.unit, 'pts');

        expect(
          () => repository.generateReport(
            analysisId: 'unknown',
            title: 'Rapport test',
            description: '',
            format: ReportFormat.pdf,
          ),
          throwsA(isA<AdminRepositoryException>()),
        );
        final report = repository.generateReport(
          analysisId: analysis.id,
          title: 'Rapport test',
          description: 'Résumé',
          format: ReportFormat.csv,
        );
        expect(report.analysisId, analysis.id);
        expect(report.format, ReportFormat.csv);
        expect(report.indicators, analysis.indicators);
      } finally {
        repository.dispose();
      }
    },
  );

  test(
    'Analysis form validates and result resolves the created analysis',
    () async {
      final repository = AdminRepository();
      final form = AnalysisFormCubit(
        repository,
        preselectedZoneId: 'mfoundi-centre',
      );
      try {
        expect(form.state.selectedZoneIds, {'mfoundi-centre'});
        final analysis = await form.generateAnalysis();
        expect(analysis, isNotNull);

        final result = AnalysisResultCubit(repository, analysis!.id);
        expect(result.state.status, AnalysisResultStatus.success);
        expect(result.state.analysis?.id, analysis.id);
        expect(result.state.zones.single.id, 'mfoundi-centre');
        await result.close();

        final invalidForm = AnalysisFormCubit(repository);
        final missingZones = await invalidForm.generateAnalysis();
        expect(missingZones, isNull);
        expect(invalidForm.state.zonesError, isNotNull);
        await invalidForm.close();
      } finally {
        await form.close();
        repository.dispose();
      }
    },
  );

  testWidgets('Admin report and zone detail fit common viewport widths', (
    WidgetTester tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    for (final width in [320.0, 360.0, 390.0, 600.0, 1024.0]) {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;

      await tester.pumpWidget(
        RepositoryProvider<AdminRepository>(
          create: (_) => AdminRepository(),
          dispose: (repository) => repository.dispose(),
          child: MaterialApp(
            home: AdminNewAnalysisPage(
              key: ValueKey('analysis-$width'),
              preselectedZoneId: 'mfoundi-centre',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'New analysis form at $width px',
      );

      await tester.pumpWidget(
        RepositoryProvider<AdminRepository>(
          create: (_) => AdminRepository(),
          dispose: (repository) => repository.dispose(),
          child: MaterialApp(
            home: AdminAnalysisResultPage(
              key: ValueKey('analysis-result-$width'),
              analysisId: 'analysis_demo_default',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Analysis result at $width px',
      );

      await tester.pumpWidget(
        RepositoryProvider<AdminRepository>(
          create: (_) => AdminRepository(),
          dispose: (repository) => repository.dispose(),
          child: MaterialApp(
            home: AdminGenerateReportPage(key: ValueKey('report-$width')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Report form at $width px',
      );

      await tester.pumpWidget(
        RepositoryProvider<AdminRepository>(
          create: (_) => AdminRepository(),
          dispose: (repository) => repository.dispose(),
          child: MaterialApp(
            home: AdminZoneDetailsPage(
              key: ValueKey('zone-$width'),
              zoneId: 'mfoundi-centre',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Zone details at $width px',
      );

      await tester.pumpWidget(
        RepositoryProvider<AdminRepository>(
          create: (_) => AdminRepository(),
          dispose: (repository) => repository.dispose(),
          child: MaterialApp(
            home: AdminZoneAnalysisPage(zoneId: 'mfoundi-centre'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Zone analysis at $width px',
      );
    }
  });
}
