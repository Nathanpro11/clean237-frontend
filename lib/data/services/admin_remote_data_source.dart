abstract interface class AdminRemoteDataSource {
  Future<Map<String, dynamic>> getDashboard();
  Future<List<Map<String, dynamic>>> getProblematicZones();
  Future<List<Map<String, dynamic>>> getZones();
  Future<Map<String, dynamic>> getZoneDetails(String zoneId);
  Future<Map<String, dynamic>> getEnvironmentalData({
    String? zoneId,
    String? type,
    int page = 1,
    int limit = 20,
    String sort = 'date',
    String order = 'desc',
  });
  Future<Map<String, dynamic>> getEnvironmentalDataById(String id);
  Future<Map<String, dynamic>> getAlerts({
    String? severity,
    String? zoneId,
    String? status,
    String? search,
    int page = 1,
    int limit = 10,
  });
  Future<Map<String, dynamic>> getAlertById(String id);
  Future<Map<String, dynamic>> treatAlert(String id);
  Future<Map<String, dynamic>> generateAnalysis({
    String? type,
    String? zoneId,
    DateTime? start,
    DateTime? end,
  });
  Future<Map<String, dynamic>> getAnalysisById(String id);
  Future<String?> deleteAnalysis(String id);
  Future<Map<String, dynamic>> generateReport({
    required String title,
    String? description,
    required String analysisId,
    String? type,
    required String format,
  });
  Future<Map<String, dynamic>> getReports({
    int page = 1,
    int limit = 10,
    String sort = 'createdAt',
    String order = 'desc',
    String? search,
    String? status,
    String? type,
    String? zoneId,
  });
  Future<Map<String, dynamic>> getReportById(String id);
  Future<String?> deleteReport(String id);
  Future<Map<String, dynamic>> updateReportStatus(String id, String status);
  Future<List<int>> exportReport(String id, String format);
}
