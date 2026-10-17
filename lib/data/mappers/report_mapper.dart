import '../../features/administration_reporting/models/analysis_model.dart';
import '../../features/administration_reporting/models/report_model.dart';
import '../dto/analysis_dto.dart';
import '../dto/report_dto.dart';

class ReportMapper {
  const ReportMapper();

  AdminReport fromDto(ReportDto dto) {
    final rawStatistics = dto.statistiques;
    final indicators = rawStatistics.isEmpty
        ? null
        : _mapIndicators(rawStatistics);
    return AdminReport(
      id: dto.id,
      title: dto.titre,
      typeName: dto.type,
      status: mapStatus(dto.statut),
      format: mapFormat(dto.format),
      zones: dto.zones
          .map((zone) => ReportZone(id: zone.id, name: zone.nom))
          .toList(growable: false),
      analysisId: dto.analysisId,
      createdAt: dto.createdAt,
      description: dto.description,
      indicators: indicators,
    );
  }

  static ReportStatus mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pret':
        return ReportStatus.ready;
      case 'en_cours':
        return ReportStatus.inProgress;
      case 'archive':
        return ReportStatus.archived;
      default:
        throw FormatException('Statut de rapport inconnu : $status');
    }
  }

  static ReportFormat mapFormat(String format) {
    switch (format.toLowerCase()) {
      case 'csv':
        return ReportFormat.csv;
      case 'pdf':
        return ReportFormat.pdf;
      default:
        throw FormatException('Format de rapport non pris en charge : $format');
    }
  }

  AnalysisIndicators _mapIndicators(Map<String, dynamic> json) {
    final dto = AnalysisIndicatorsDto.fromJson(json);
    return AnalysisIndicators(
      totalPoints: dto.totalPoints,
      byType: dto.parType.map(
        (type, value) => MapEntry(
          type,
          AnalysisTypeIndicator(
            count: value.count,
            average: value.moyenne.toDouble(),
            minimum: value.minimum.toDouble(),
            maximum: value.maximum.toDouble(),
            sum: value.somme.toDouble(),
            unit: value.unite,
          ),
        ),
      ),
    );
  }
}
