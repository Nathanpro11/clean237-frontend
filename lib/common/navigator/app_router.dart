import 'package:go_router/go_router.dart';

import 'app_routes.dart';
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
    initialLocation: AppRoutes.dashboard,
    errorBuilder: (context, state) => AdminExportFailurePage(
      title: 'Page non trouvée',
      errorMessage:
          'La page demandée "${state.uri.toString()}" n’existe pas dans le module Clean237.',
    ),
    routes: [
      GoRoute(path: '/', redirect: (context, state) => AppRoutes.dashboard),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.zones,
        builder: (context, state) {
          final filter = state.uri.queryParameters['filter'];
          return AdminZonesPage(initialFilter: filter);
        },
        routes: [
          GoRoute(
            path: AppRoutes.criticalSegment,
            builder: (context, state) => const AdminCriticalZonesPage(),
          ),
          GoRoute(
            path: AppRoutes.zoneIdSegment,
            builder: (context, state) {
              final zoneId = state.pathParameters['zoneId'];
              if (zoneId == null || zoneId.isEmpty) {
                return const AdminExportFailurePage(
                  title: 'Zone introuvable',
                  errorMessage: 'Aucun identifiant de zone n’a été fourni.',
                );
              }
              return AdminZoneDetailsPage(zoneId: zoneId);
            },
            routes: [
              GoRoute(
                path: AppRoutes.zoneAnalysisSegment,
                builder: (context, state) {
                  final zoneId = state.pathParameters['zoneId'];
                  if (zoneId == null || zoneId.isEmpty) {
                    return const AdminExportFailurePage(
                      title: 'Zone introuvable',
                      errorMessage: 'Aucun identifiant de zone n’a été fourni.',
                    );
                  }
                  return AdminZoneAnalysisPage(zoneId: zoneId);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.alerts,
        builder: (context, state) => const AdminAlertsPage(),
        routes: [
          GoRoute(
            path: AppRoutes.alertIdSegment,
            builder: (context, state) {
              final alertId = state.pathParameters['alertId'] ?? 'alert_1';
              return AdminAlertDetailsPage(alertId: alertId);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.reports,
        builder: (context, state) => const AdminReportsPage(),
        routes: [
          GoRoute(
            path: AppRoutes.generateReportSegment,
            builder: (context, state) {
              final preselectedZoneId =
                  state.uri.queryParameters['preselectedZoneId'];
              return AdminGenerateReportPage(
                preselectedZoneId: preselectedZoneId,
              );
            },
          ),
          GoRoute(
            path: AppRoutes.reportIdSegment,
            builder: (context, state) {
              final reportId = state.pathParameters['reportId'] ?? 'report_1';
              return AdminReportPreviewPage(reportId: reportId);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.exportSuccessPath,
        builder: (context, state) {
          final title = state.uri.queryParameters['title'] ?? 'Rapport';
          final file = state.uri.queryParameters['file'];
          return AdminExportSuccessPage(title: title, fileName: file);
        },
      ),
      GoRoute(
        path: AppRoutes.exportFailurePath,
        builder: (context, state) {
          final title = state.uri.queryParameters['title'] ?? 'Rapport';
          final error = state.uri.queryParameters['error'];
          return AdminExportFailurePage(title: title, errorMessage: error);
        },
      ),
    ],
  );
}
