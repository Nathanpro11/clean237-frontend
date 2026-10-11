import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clean237_frontend/main.dart';
import 'package:clean237_frontend/common/widgets/filter_chip_group.dart';
import 'package:clean237_frontend/data/repositories/admin_repository.dart';
import 'package:clean237_frontend/features/administration_reporting/controller/admin_export_controller.dart';
import 'package:clean237_frontend/features/administration_reporting/screen/admin_generate_report_page.dart';
import 'package:clean237_frontend/features/administration_reporting/screen/admin_zone_details_page.dart';
import 'package:clean237_frontend/features/administration_reporting/screen/admin_zone_analysis_page.dart';

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

  testWidgets('AdminExportController handles export flow', (
    WidgetTester tester,
  ) async {
    final controller = AdminExportController();
    expect(controller.status, ExportStatus.idle);
    expect(controller.isExporting, false);

    final future = controller.startExport(
      reportTitle: 'Test Report',
      delay: Duration.zero,
    );
    await future;
    expect(controller.status, ExportStatus.success);
    expect(controller.generatedFilePath, isNotNull);
  });

  testWidgets('AdminRepository handles data updates', (
    WidgetTester tester,
  ) async {
    final repo = AdminRepository();
    expect(repo.allZones.length, 12);
    expect(repo.criticalZones.length, 2);
    expect(repo.allAlerts.length, 7);
  });

  testWidgets('Admin report and zone detail fit common viewport widths', (
    WidgetTester tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    for (final width in [320.0, 390.0, 600.0, 1024.0]) {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: AdminGenerateReportPage(key: ValueKey('report-$width')),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Report form at $width px',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AdminZoneDetailsPage(
            key: ValueKey('zone-$width'),
            zoneId: 'mfoundi-centre',
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
        MaterialApp(home: AdminZoneAnalysisPage(zoneId: 'mfoundi-centre')),
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
