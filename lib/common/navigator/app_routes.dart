abstract final class AppRoutes {
  static const dashboard = '/admin/dashboard';
  static const zones = '/admin/zones';
  static const criticalZones = '/admin/zones/critical';
  static const alerts = '/admin/alerts';
  static const reports = '/admin/reports';
  static const analyses = '/admin/analyses';
  static const newAnalysisPath = '/admin/analyses/new';
  static const newReportPath = '/admin/reports/new';
  static const generateReportPath = '/admin/reports/generate';
  static const exportSuccessPath = '/admin/export/success';
  static const exportFailurePath = '/admin/export/failure';

  static const criticalSegment = 'critical';
  static const zoneIdSegment = ':zoneId';
  static const zoneAnalysisSegment = 'analysis';
  static const analysisIdSegment = ':analyseId';
  static const alertIdSegment = ':alertId';
  static const reportIdSegment = ':reportId';
  static const generateReportSegment = 'generate';

  static String zoneDetails(String zoneId) =>
      '$zones/${Uri.encodeComponent(zoneId)}';

  static String zoneAnalysis(String zoneId) =>
      '${zoneDetails(zoneId)}/$zoneAnalysisSegment';

  static String newAnalysis({String? zoneId}) => Uri(
    path: newAnalysisPath,
    queryParameters: {'zoneId': ?zoneId},
  ).toString();

  static String analysisResult(String analysisId) =>
      '$analyses/${Uri.encodeComponent(analysisId)}';

  static String newReport({required String analysisId}) => Uri(
    path: newReportPath,
    queryParameters: {'analyseId': analysisId},
  ).toString();

  static String alertDetails(String alertId) =>
      '$alerts/${Uri.encodeComponent(alertId)}';

  static String reportPreview(String reportId) =>
      '$reports/${Uri.encodeComponent(reportId)}';

  static String generateReport({String? preselectedZoneId}) {
    return Uri(
      path: generateReportPath,
      queryParameters: {'preselectedZoneId': ?preselectedZoneId},
    ).toString();
  }

  static String exportSuccess({required String title, String? file}) => Uri(
    path: exportSuccessPath,
    queryParameters: {'title': title, 'file': ?file},
  ).toString();

  static String exportFailure({required String title, String? error}) => Uri(
    path: exportFailurePath,
    queryParameters: {'title': title, 'error': ?error},
  ).toString();
}
