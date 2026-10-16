import '../../features/administration_reporting/models/zone_model.dart';
import '../dto/problematic_zone_dto.dart';
import '../dto/zone_details_dto.dart';

class ZoneMapper {
  const ZoneMapper();

  Zone fromProblematicZone(ProblematicZoneDto dto) => Zone(
    id: dto.zoneId,
    name: dto.nom,
    score: dto.score,
    severityScore: dto.score,
    status: mapLevel(dto.niveau),
    lastUpdatedAt: _parseDate(dto.details['derniereDonnee']),
    alertCount: (dto.details['alertCount'] as num?)?.toInt(),
    dataCount: (dto.details['dataCount'] as num?)?.toInt(),
  );

  Zone fromDetails(ZoneDetailsDto dto) => Zone(
    id: dto.id,
    name: dto.nom,
    score: dto.score,
    severityScore: dto.score,
    status: mapLevel(dto.niveau),
    evolutionPoints: dto.evolutionPoints,
    lastUpdatedAt: dto.derniereMiseAJour,
    alertCount: dto.alertCount,
    dataCount: dto.dataCount,
    evolution30Days: dto.evolution30Jours
        .map((point) => point.score.toDouble())
        .toList(growable: false),
    interpretation: dto.interpretation,
    priorities: dto.priorites,
  );

  static ZoneStatus mapLevel(String level) {
    switch (level.trim().toLowerCase()) {
      case 'critique':
      case 'critical':
        return ZoneStatus.critical;
      case 'problématique':
      case 'problematique':
      case 'à surveiller':
      case 'a surveiller':
      case 'warning':
        return ZoneStatus.warning;
      case 'normal':
        return ZoneStatus.normal;
      default:
        throw FormatException('Niveau de zone inconnu : $level');
    }
  }

  DateTime? _parseDate(Object? value) =>
      value == null ? null : DateTime.parse(value.toString()).toUtc();
}
