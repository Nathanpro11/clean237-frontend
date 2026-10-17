import '../../features/administration_reporting/models/zone_model.dart';
import '../dto/dashboard_dto.dart';

class DashboardMapper {
  const DashboardMapper();

  Map<String, dynamic> toDomain(DashboardDto dto) {
    return <String, dynamic>{
      'totalZones': dto.totalZones,
      'totalDataPoints': dto.totalDataPoints,
      'dataByType': dto.dataByType,
      'totalAnalyses': dto.totalAnalyses,
      'analysesWithResult': dto.analysesWithResult,
      'totalReports': dto.totalReports,
      'reportsWithStats': dto.reportsWithStats,
      'zonesCritiques': dto.zonesCritiques,
    };
  }

  ZoneStatus mapSeverity(String level) {
    switch (level.toLowerCase()) {
      case 'critique':
        return ZoneStatus.critical;
      case 'problématique':
      case 'à surveiller':
        return ZoneStatus.warning;
      case 'normal':
      default:
        return ZoneStatus.normal;
    }
  }
}
