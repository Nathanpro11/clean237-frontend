import 'package:go_router/go_router.dart';

import '../../features/administration_reporting/models/report_model.dart';
import 'app_routes.dart';
import '../../features/administration_reporting/screen/admin_alerts_page.dart';
import '../../features/administration_reporting/screen/admin_alert_details_page.dart';
import '../../features/administration_reporting/screen/admin_analysis_result_page.dart';
import '../../features/administration_reporting/screen/admin_critical_zones_page.dart';
import '../../features/administration_reporting/screen/admin_dashboard_page.dart';
import '../../features/administration_reporting/screen/admin_export_failure_page.dart';
import '../../features/administration_reporting/screen/admin_export_success_page.dart';
import '../../features/administration_reporting/screen/admin_generate_report_page.dart';
import '../../features/administration_reporting/screen/admin_new_analysis_page.dart';
import '../../features/administration_reporting/screen/admin_report_preview_page.dart';
import '../../features/administration_reporting/screen/admin_reports_page.dart';
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
        path: AppRoutes.newAnalysisPath,
        builder: (context, state) => AdminNewAnalysisPage(
          preselectedZoneId: state.uri.queryParameters['zoneId'],
        ),
      ),
      GoRoute(
        path: '${AppRoutes.analyses}/${AppRoutes.analysisIdSegment}',
        builder: (context, state) {
          final analysisId = state.pathParameters['analyseId'];
          if (analysisId == null || analysisId.isEmpty) {
            return const AdminExportFailurePage(
              title: 'Analyse introuvable',
              errorMessage: 'Aucun identifiant d’analyse n’a été fourni.',
            );
          }
          return AdminAnalysisResultPage(analysisId: analysisId);
        },
      ),
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
                redirect: (context, state) => AppRoutes.newAnalysis(
                  zoneId: state.pathParameters['zoneId'],
                ),
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
            path: AppRoutes.newReportSegment,
            builder: (context, state) => AdminGenerateReportPage(
              analysisId: state.uri.queryParameters['analyseId'],
              initialTitle: state.uri.queryParameters['title'],
              initialDescription:
                  state.uri.queryParameters['description'] ?? '',
              initialFormat: ReportFormat.values.firstWhere(
                (format) => format.name == state.uri.queryParameters['format'],
                orElse: () => ReportFormat.pdf,
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.generateReportSegment,
            redirect: (context, state) => AppRoutes.newAnalysis(
              zoneId:
                  state.uri.queryParameters['zoneId'] ??
                  state.uri.queryParameters['preselectedZoneId'],
            ),
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
          final analysisId = state.uri.queryParameters['analyseId'];
          final retryPath = analysisId == null
              ? null
              : AppRoutes.newReport(
                  analysisId: analysisId,
                  title: title,
                  description: state.uri.queryParameters['description'] ?? '',
                  format: state.uri.queryParameters['format'],
                );
          return AdminExportFailurePage(
            title: title,
            errorMessage: error,
            retryPath: retryPath,
          );
        },
      ),
    ],
  );
}
