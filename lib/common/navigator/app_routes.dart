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
  static const newReportSegment = 'new';

  static String zoneDetails(String zoneId) =>
      '$zones/${Uri.encodeComponent(zoneId)}';

  static String newAnalysis({
    String? zoneId,
    String? message,
    bool createReport = false,
  }) => Uri(
    path: newAnalysisPath,
    queryParameters: {
      'zoneId': ?zoneId,
      'message': ?message,
      if (createReport) 'createReport': 'true',
    },
  ).toString();

  static String analysisResult(String analysisId) =>
      '$analyses/${Uri.encodeComponent(analysisId)}';

  static String newReport({
    required String analysisId,
    String? title,
    String? description,
    String? format,
  }) => Uri(
    path: newReportPath,
    queryParameters: {
      'analyseId': analysisId,
      'title': ?title,
      'description': ?description,
      'format': ?format,
    },
  ).toString();

  static String alertDetails(String alertId) =>
      '$alerts/${Uri.encodeComponent(alertId)}';

  static String reportPreview(String reportId) =>
      '$reports/${Uri.encodeComponent(reportId)}';

  static String exportSuccess({
    required String title,
    String? fileName,
    String? filePath,
    String? format,
  }) => Uri(
    path: exportSuccessPath,
    queryParameters: {
      'title': title,
      'fileName': ?fileName,
      'filePath': ?filePath,
      'format': ?format,
    },
  ).toString();

  static String exportFailure({
    required String title,
    String? error,
    String? analysisId,
    String? reportId,
    String? description,
    String? format,
  }) => Uri(
    path: exportFailurePath,
    queryParameters: {
      'title': title,
      'error': ?error,
      'analyseId': ?analysisId,
      'reportId': ?reportId,
      'description': ?description,
      'format': ?format,
    },
  ).toString();
}
