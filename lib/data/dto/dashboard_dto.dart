class DashboardDto {
  const DashboardDto({
    required this.totalZones,
    required this.totalDataPoints,
    required this.totalAnalyses,
    required this.analysesWithResult,
    required this.totalReports,
    required this.reportsWithStats,
    required this.zonesCritiques,
    required this.alertesActives,
    required this.dataByType,
  });

  final int totalZones;
  final int totalDataPoints;
  final int totalAnalyses;
  final int analysesWithResult;
  final int totalReports;
  final int reportsWithStats;
  final int zonesCritiques;
  final int alertesActives;
  final Map<String, int> dataByType;

  factory DashboardDto.fromJson(Map<String, dynamic> json) {
    final rawDashboard = json['dashboard'] is Map ? json['dashboard'] as Map : const {};
    final dataByTypeMap = rawDashboard['dataByType'] is Map
        ? Map<String, dynamic>.from(rawDashboard['dataByType'] as Map)
        : const <String, dynamic>{};

    return DashboardDto(
      totalZones: (rawDashboard['totalZones'] as num? ?? 0).toInt(),
      totalDataPoints: (rawDashboard['totalDataPoints'] as num? ?? 0).toInt(),
      totalAnalyses: (rawDashboard['totalAnalyses'] as num? ?? 0).toInt(),
      analysesWithResult: (rawDashboard['analysesWithResult'] as num? ?? 0).toInt(),
      totalReports: (rawDashboard['totalReports'] as num? ?? 0).toInt(),
      reportsWithStats: (rawDashboard['reportsWithStats'] as num? ?? 0).toInt(),
      zonesCritiques: (rawDashboard['zonesCritiques'] as num? ?? 0).toInt(),
      alertesActives: (rawDashboard['alertesActives'] as num? ?? 0).toInt(),
      dataByType: dataByTypeMap.map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      ),
    );
  }
}
