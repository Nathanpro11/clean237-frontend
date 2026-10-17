import '../../features/administration_reporting/models/alert_model.dart';
import '../dto/alert_dto.dart';

class AlertMapper {
  const AlertMapper();

  AdminAlert fromDto(AlertDto dto) => AdminAlert(
    id: dto.id,
    title: dto.titre,
    subtitle: dto.sousTitre,
    zoneId: dto.zoneId,
    zoneName: dto.zoneNom,
    dateTime: dto.date,
    severity: mapSeverity(dto.severite),
    status: switch (dto.statut.toLowerCase()) {
      'traitee' => AlertStatus.treated,
      'active' => AlertStatus.active,
      _ => throw FormatException('Statut d’alerte inconnu : ${dto.statut}'),
    },
  );

  static AlertSeverity mapSeverity(String severity) {
    switch (severity.toLowerCase()) {
      case 'critique':
        return AlertSeverity.critical;
      case 'avertissement':
        return AlertSeverity.warning;
      case 'info':
        return AlertSeverity.info;
      default:
        throw FormatException('Sévérité d’alerte inconnue : $severity');
    }
  }
}
