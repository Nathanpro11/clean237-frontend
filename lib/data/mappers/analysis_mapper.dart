import '../../features/administration_reporting/models/analysis_model.dart';
import '../dto/analysis_dto.dart';

class AnalysisMapper {
  const AnalysisMapper();

  Analysis fromDto(AnalysisDto dto) => Analysis(
    id: dto.id,
    type: dto.type,
    zoneId: dto.zoneId,
    zoneName: dto.zoneNom,
    periodStart: DateTime.parse(dto.periode['start'].toString()).toUtc(),
    periodEnd: DateTime.parse(dto.periode['end'].toString()).toUtc(),
    result: dto.resultat,
    indicators: AnalysisIndicators(
      totalPoints: dto.indicateurs.totalPoints,
      byType: dto.indicateurs.parType.map(
        (type, value) => MapEntry(type, _toDomain(value)),
      ),
    ),
    createdAt: dto.createdAt,
  );

  AnalysisTypeIndicator _toDomain(AnalysisTypeIndicatorDto dto) =>
      AnalysisTypeIndicator(
        count: dto.count,
        average: dto.moyenne.toDouble(),
        minimum: dto.minimum.toDouble(),
        maximum: dto.maximum.toDouble(),
        sum: dto.somme.toDouble(),
        unit: dto.unite,
      );
}
