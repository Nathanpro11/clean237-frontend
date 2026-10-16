import '../dto/alert_dto.dart';
import '../dto/analysis_dto.dart';
import '../dto/dashboard_dto.dart';
import '../dto/environmental_data_dto.dart';
import '../dto/pagination_dto.dart';
import '../dto/problematic_zone_dto.dart';
import '../dto/report_dto.dart';
import '../dto/zone_details_dto.dart';
import '../exceptions/app_exception.dart';
import '../mappers/alert_mapper.dart';
import '../mappers/analysis_mapper.dart';
import '../mappers/report_mapper.dart';
import '../mappers/zone_mapper.dart';
import '../services/action_result.dart';
import '../services/admin_remote_data_source.dart';
import '../../features/administration_reporting/models/alert_model.dart';
import '../../features/administration_reporting/models/analysis_model.dart';
import '../../features/administration_reporting/models/report_model.dart';
import '../../features/administration_reporting/models/zone_model.dart';
import 'paged_result.dart';

export '../services/action_result.dart';

class AdminRepository {
  AdminRepository({
    required this._dataSource,
    this._zoneMapper = const ZoneMapper(),
    this._alertMapper = const AlertMapper(),
    this._analysisMapper = const AnalysisMapper(),
    this._reportMapper = const ReportMapper(),
  });

  final AdminRemoteDataSource _dataSource;
  final ZoneMapper _zoneMapper;
  final AlertMapper _alertMapper;
  final AnalysisMapper _analysisMapper;
  final ReportMapper _reportMapper;

  Future<DashboardDto> getDashboard() async =>
      DashboardDto.fromJson(await _dataSource.getDashboard());

  Future<List<Zone>> getProblematicZones() async {
    final zones = await _dataSource.getProblematicZones();
    return zones
        .map((zone) => _zoneMapper.fromProblematicZone(
              ProblematicZoneDto.fromJson(zone),
            ))
        .toList(growable: false);
  }

  Future<List<Zone>> getZones() => getProblematicZones();

  Future<Zone> getZoneDetails(String zoneId) async {
    final response = await _dataSource.getZoneDetails(zoneId);
    final zone = Map<String, dynamic>.from(response['zone'] as Map);
    return _zoneMapper.fromDetails(ZoneDetailsDto.fromJson(zone));
  }

  Future<PagedResult<EnvironmentalDataDto>> getEnvironmentalData({
    String? zoneId,
    String? type,
    int page = 1,
    int limit = 20,
    String sort = 'date',
    String order = 'desc',
  }) async {
    final response = await _dataSource.getEnvironmentalData(
      zoneId: zoneId,
      type: type,
      page: page,
      limit: limit,
      sort: sort,
      order: order,
    );
    return _parsePage(
      response,
      (item) => EnvironmentalDataDto.fromJson(item),
    );
  }

  Future<EnvironmentalDataDto> getEnvironmentalDataById(String id) async {
    final response = await _dataSource.getEnvironmentalDataById(id);
    return EnvironmentalDataDto.fromJson(
      Map<String, dynamic>.from(response['donnee'] as Map),
    );
  }

  Future<PagedResult<AdminAlert>> getAlerts({
    String? severity,
    String? zoneId,
    String? status,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _dataSource.getAlerts(
      severity: severity,
      zoneId: zoneId,
      status: status,
      search: search,
      page: page,
      limit: limit,
    );
    return _parsePage(
      response,
      (item) => _alertMapper.fromDto(AlertDto.fromJson(item)),
    );
  }

  Future<AdminAlert> getAlertById(String id) async {
    final response = await _dataSource.getAlertById(id);
    return _alertMapper.fromDto(
      AlertDto.fromJson(Map<String, dynamic>.from(response['alerte'] as Map)),
    );
  }

  Future<ActionResult<AdminAlert>> treatAlert(String id) async {
    final response = await _dataSource.treatAlert(id);
    final alert = _alertMapper.fromDto(
      AlertDto.fromJson(Map<String, dynamic>.from(response['alerte'] as Map)),
    );
    return ActionResult(
      data: alert,
      message: response['message'] as String?,
    );
  }

  Future<ActionResult<Analysis>> generateAnalysis({
    required DateTime periodStart,
    required DateTime periodEnd,
    String? zoneId,
    String? type,
  }) async {
    final response = await _dataSource.generateAnalysis(
      type: type,
      zoneId: zoneId,
      start: periodStart,
      end: periodEnd,
    );
    final analysis = _analysisMapper.fromDto(
      AnalysisDto.fromJson(
        Map<String, dynamic>.from(response['analyse'] as Map),
      ),
    );
    return ActionResult(
      data: analysis,
      message: response['message'] as String?,
    );
  }

  Future<Analysis> getAnalysisById(String id) async {
    final response = await _dataSource.getAnalysisById(id);
    return _analysisMapper.fromDto(
      AnalysisDto.fromJson(
        Map<String, dynamic>.from(response['analyse'] as Map),
      ),
    );
  }

  Future<String?> deleteAnalysis(String id) => _dataSource.deleteAnalysis(id);

  Future<ActionResult<AdminReport>> generateReport({
    required String analysisId,
    required String title,
    String? description,
    String? type,
    required ReportFormat format,
  }) async {
    if (format == ReportFormat.excel) {
      throw const ValidationException(
        'Le format Excel sera bientôt disponible.',
      );
    }
    if (analysisId.isEmpty) {
      throw const ValidationException('Une analyse est nécessaire pour créer un rapport.');
    }
    final response = await _dataSource.generateReport(
      title: title,
      description: description,
      analysisId: analysisId,
      type: type,
      format: format == ReportFormat.csv ? 'csv' : 'pdf',
    );
    final report = _reportMapper.fromDto(
      ReportDto.fromJson(Map<String, dynamic>.from(response['report'] as Map)),
    );
    return ActionResult(
      data: report,
      message: response['message'] as String?,
    );
  }

  Future<PagedResult<AdminReport>> getReports({
    int page = 1,
    int limit = 10,
    String sort = 'createdAt',
    String order = 'desc',
    String? search,
    String? status,
    String? type,
    String? zoneId,
  }) async {
    final response = await _dataSource.getReports(
      page: page,
      limit: limit,
      sort: sort,
      order: order,
      search: search,
      status: status,
      type: type,
      zoneId: zoneId,
    );
    return _parsePage(
      response,
      (item) => _reportMapper.fromDto(ReportDto.fromJson(item)),
    );
  }

  Future<AdminReport> getReportById(String id) async {
    final response = await _dataSource.getReportById(id);
    return _reportMapper.fromDto(
      ReportDto.fromJson(Map<String, dynamic>.from(response['report'] as Map)),
    );
  }

  Future<String?> deleteReport(String id) => _dataSource.deleteReport(id);

  Future<ActionResult<AdminReport>> updateReportStatus(
    String id,
    ReportStatus status,
  ) async {
    final rawStatus = switch (status) {
      ReportStatus.ready => 'pret',
      ReportStatus.inProgress => 'en_cours',
      ReportStatus.archived => 'archive',
    };
    final response = await _dataSource.updateReportStatus(id, rawStatus);
    final report = _reportMapper.fromDto(
      ReportDto.fromJson(Map<String, dynamic>.from(response['report'] as Map)),
    );
    return ActionResult(
      data: report,
      message: response['message'] as String?,
    );
  }

  Future<List<int>> exportReport(String id, ReportFormat format) {
    if (format == ReportFormat.excel) {
      throw const ValidationException(
        'Le format Excel sera bientôt disponible.',
      );
    }
    return _dataSource.exportReport(
      id,
      format == ReportFormat.csv ? 'csv' : 'pdf',
    );
  }

  PagedResult<T> _parsePage<T>(
    Map<String, dynamic> response,
    T Function(Map<String, dynamic>) parseItem,
  ) {
    final rawData = response['data'] as List? ?? const [];
    final rawPagination = response['pagination'] is Map
        ? Map<String, dynamic>.from(response['pagination'] as Map)
        : const <String, dynamic>{};
    return PagedResult<T>(
      items: rawData
          .map((item) => parseItem(Map<String, dynamic>.from(item as Map)))
          .toList(growable: false),
      pagination: PaginationDto.fromJson(rawPagination),
    );
  }
}
