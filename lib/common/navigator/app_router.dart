import 'package:go_router/go_router.dart';

import '../../features/administration_reporting/screen/admin_alerts_page.dart';
import '../../features/administration_reporting/screen/admin_alert_details_page.dart';
import '../../features/administration_reporting/screen/admin_critical_zones_page.dart';
import '../../features/administration_reporting/screen/admin_dashboard_page.dart';
import '../../features/administration_reporting/screen/admin_export_failure_page.dart';
import '../../features/administration_reporting/screen/admin_export_success_page.dart';
import '../../features/administration_reporting/screen/admin_generate_report_page.dart';
import '../../features/administration_reporting/screen/admin_report_preview_page.dart';
import '../../features/administration_reporting/screen/admin_reports_page.dart';
import '../../features/administration_reporting/screen/admin_zone_analysis_page.dart';
import '../../features/administration_reporting/screen/admin_zone_details_page.dart';
import '../../features/administration_reporting/screen/admin_zones_page.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/admin/dashboard',
    errorBuilder: (context, state) => AdminExportFailurePage(
      title: 'Page non trouvée',
      errorMessage:
          'La page demandée "${state.uri.toString()}" n’existe pas dans le module Clean237.',
    ),
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/admin/dashboard'),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: '/admin/zones',
        builder: (context, state) {
          final filter = state.uri.queryParameters['filter'];
          return AdminZonesPage(initialFilter: filter);
        },
        routes: [
          GoRoute(
            path: 'critical',
            builder: (context, state) => const AdminCriticalZonesPage(),
          ),
          GoRoute(
            path: ':zoneId',
            builder: (context, state) {
              final zoneId = state.pathParameters['zoneId'] ?? 'mfoundi-centre';
              return AdminZoneDetailsPage(zoneId: zoneId);
            },
            routes: [
              GoRoute(
                path: 'analysis',
                builder: (context, state) {
                  final zoneId =
                      state.pathParameters['zoneId'] ?? 'mfoundi-centre';
                  return AdminZoneAnalysisPage(zoneId: zoneId);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/admin/alerts',
        builder: (context, state) => const AdminAlertsPage(),
        routes: [
          GoRoute(
            path: ':alertId',
            builder: (context, state) {
              final alertId = state.pathParameters['alertId'] ?? 'alert_1';
              return AdminAlertDetailsPage(alertId: alertId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/admin/reports',
        builder: (context, state) => const AdminReportsPage(),
        routes: [
          GoRoute(
            path: 'generate',
            builder: (context, state) {
              final preselectedZoneId =
                  state.uri.queryParameters['preselectedZoneId'];
              return AdminGenerateReportPage(
                preselectedZoneId: preselectedZoneId,
              );
            },
          ),
          GoRoute(
            path: ':reportId',
            builder: (context, state) {
              final reportId = state.pathParameters['reportId'] ?? 'report_1';
              return AdminReportPreviewPage(reportId: reportId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/admin/export/success',
        builder: (context, state) {
          final title = state.uri.queryParameters['title'] ?? 'Rapport';
          final file = state.uri.queryParameters['file'];
          return AdminExportSuccessPage(title: title, fileName: file);
        },
      ),
      GoRoute(
        path: '/admin/export/failure',
        builder: (context, state) {
          final title = state.uri.queryParameters['title'] ?? 'Rapport';
          final error = state.uri.queryParameters['error'];
          return AdminExportFailurePage(title: title, errorMessage: error);
        },
      ),
    ],
  );
}
