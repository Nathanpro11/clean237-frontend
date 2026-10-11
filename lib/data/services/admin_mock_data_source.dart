import '../../features/administration_reporting/models/alert_model.dart';
import '../../features/administration_reporting/models/analysis_model.dart';
import '../../features/administration_reporting/models/report_model.dart';
import '../../features/administration_reporting/models/zone_model.dart';

class AdminMockDataSource {
  final List<Zone> zones = [
    const Zone(
      id: 'mfoundi-centre',
      name: 'Mfoundi Centre',
      score: 42,
      status: ZoneStatus.critical,
      evolutionPoints: -12,
      lastUpdate: 'il y a 12 min',
      evolution30Days: [65, 62, 58, 54, 50, 46, 44, 42],
      interpretation: 'La régularité des collectes baisse depuis deux semaines. Prioriser le marché central et renforcer le passage du matin.',
      priorities: [
        'Planifier une collecte sous 24 h',
        'Vérifier les trois dépôts signalés',
      ],
    ),
    const Zone(
      id: 'biyem-assi',
      name: 'Biyem-Assi',
      score: 61,
      status: ZoneStatus.warning,
      evolutionPoints: -5,
      lastUpdate: 'il y a 28 min',
      evolution30Days: [70, 68, 66, 65, 63, 62, 60, 61],
      interpretation: 'Zone à surveiller. Légère surcharge constatée le week-end au niveau du carrefour Acacias.',
      priorities: [
        'Ajuster les rotations du samedi',
        'Sensibiliser les commerces riverains',
      ],
    ),
    const Zone(
      id: 'bastos',
      name: 'Bastos',
      score: 86,
      status: ZoneStatus.normal,
      evolutionPoints: 4,
      lastUpdate: 'il y a 45 min',
      evolution30Days: [80, 82, 83, 84, 85, 86, 85, 86],
      interpretation: 'Situation excellente. Circuit de collecte fluide et taux de valorisation en progression.',
      priorities: ['Maintenir la fréquence actuelle'],
    ),
    const Zone(
      id: 'mokolo-marche',
      name: 'Mokolo Marché',
      score: 38,
      status: ZoneStatus.critical,
      evolutionPoints: -15,
      lastUpdate: 'il y a 5 min',
      evolution30Days: [55, 52, 48, 45, 42, 40, 39, 38],
      interpretation: 'Afflux massif d’encombrants maraîchers. Risque d’obstruction des caniveaux.',
      priorities: [
        'Déployer une benne supplémentaire',
        'Contrôler les dépôts illégaux de nuit',
      ],
    ),
    const Zone(
      id: 'ngoa-ekelle',
      name: 'Ngoa-Ekellé',
      score: 82,
      status: ZoneStatus.normal,
      evolutionPoints: 2,
      lastUpdate: 'il y a 1h',
    ),
    const Zone(
      id: 'nkolbisson',
      name: 'Nkolbisson',
      score: 58,
      status: ZoneStatus.warning,
      evolutionPoints: -3,
      lastUpdate: 'il y a 2h',
    ),
    const Zone(
      id: 'omnisports',
      name: 'Omnisports',
      score: 79,
      status: ZoneStatus.normal,
      evolutionPoints: 1,
      lastUpdate: 'il y a 3h',
    ),
    const Zone(
      id: 'melen',
      name: 'Melen',
      score: 74,
      status: ZoneStatus.normal,
      evolutionPoints: 0,
      lastUpdate: 'il y a 3h',
    ),
    const Zone(
      id: 'essos',
      name: 'Essos',
      score: 76,
      status: ZoneStatus.normal,
      evolutionPoints: 3,
      lastUpdate: 'il y a 4h',
    ),
    const Zone(
      id: 'tsinga',
      name: 'Tsinga',
      score: 88,
      status: ZoneStatus.normal,
      evolutionPoints: 5,
      lastUpdate: 'il y a 5h',
    ),
    const Zone(
      id: 'mvog-ada',
      name: 'Mvog-Ada',
      score: 70,
      status: ZoneStatus.normal,
      evolutionPoints: -2,
      lastUpdate: 'il y a 6h',
    ),
    const Zone(
      id: 'mimboman',
      name: 'Mimboman',
      score: 72,
      status: ZoneStatus.normal,
      evolutionPoints: 1,
      lastUpdate: 'il y a 6h',
    ),
  ];

  final List<AdminAlert> alerts = [
    const AdminAlert(
      id: 'alert_1',
      title: 'Collecte en retard · 2 j',
      subtitle: 'Dernière collecte il y a 48 h',
      zoneId: 'mfoundi-centre',
      zoneName: 'Mfoundi Centre',
      date: '03 oct. 2026',
      context: 'Retard de passage de la benne de collecte sur l’axe principal du marché.',
      impact: 'Saturation des bacs et débordements sur la chaussée.',
      severity: AlertSeverity.critical,
    ),
    const AdminAlert(
      id: 'alert_2',
      title: '3 dépôts non traités',
      subtitle: '2 dépôts en attente depuis hier',
      zoneId: 'mfoundi-centre',
      zoneName: 'Mfoundi Centre',
      date: '02 oct. 2026',
      context: 'Trois dépôts sauvages signalés par les riverains aux abords du complexe scolaire.',
      impact: 'Risque sanitaire et encombrement de la voie publique.',
      severity: AlertSeverity.critical,
    ),
    const AdminAlert(
      id: 'alert_3',
      title: 'Capteur saturé · Marché central',
      subtitle: 'Niveau critique détecté à 08:42',
      zoneId: 'mfoundi-centre',
      zoneName: 'Mfoundi Centre',
      date: '03 oct. 2026 à 08:42',
      context: 'Le capteur volumétrique du bac B-12 a dépassé 95% de sa capacité nominale.',
      impact: 'Nécessite une vidange d’urgence sous 2 heures.',
      severity: AlertSeverity.critical,
    ),
    const AdminAlert(
      id: 'alert_4',
      title: 'Dépôt sauvage en expansion',
      subtitle: 'Signalement citoyen validé',
      zoneId: 'biyem-assi',
      zoneName: 'Biyem-Assi',
      date: '02 oct. 2026',
      context: 'Accumulation d’encombrants au carrefour Acacias.',
      impact: 'Gêne pour la circulation des piétons.',
      severity: AlertSeverity.warning,
    ),
    const AdminAlert(
      id: 'alert_5',
      title: 'Bac endommagé',
      subtitle: 'Remplacement requis',
      zoneId: 'mokolo-marche',
      zoneName: 'Mokolo Marché',
      date: '01 oct. 2026',
      context: 'Couvercle cassé et fissure sur la cuve après collecte.',
      impact: 'Odeurs et insalubrité.',
      severity: AlertSeverity.critical,
    ),
    const AdminAlert(
      id: 'alert_6',
      title: 'Ralentissement rotation benne',
      subtitle: 'Incident mécanique mineur',
      zoneId: 'biyem-assi',
      zoneName: 'Biyem-Assi',
      date: '03 oct. 2026',
      context: 'Camion benne C-04 en révision express d’urgence.',
      impact: 'Décalage prévisionnel de 4 h sur la tournée.',
      severity: AlertSeverity.warning,
    ),
    const AdminAlert(
      id: 'alert_7',
      title: 'Collecte nocturne incomplète',
      subtitle: 'Accès bloqué par travaux',
      zoneId: 'mvog-ada',
      zoneName: 'Mvog-Ada',
      date: '02 oct. 2026',
      context: 'Rue principale barrée pour travaux d’assainissement.',
      impact: '3 points d’apport volontaire non collectés.',
      severity: AlertSeverity.warning,
    ),
  ];

  late final List<Analysis> analyses = [
    _demoAnalysis(
      id: 'analysis_demo_default',
      type: 'Synthèse mensuelle',
      zoneIds: [
        'mfoundi-centre',
        'biyem-assi',
        'bastos',
        'mokolo-marche',
        'mvog-ada',
      ],
      periodStart: DateTime(2026, 9),
      periodEnd: DateTime(2026, 9, 30),
      createdAt: DateTime(2026, 9, 22),
    ),
    _demoAnalysis(
      id: 'analysis_demo_report_2',
      type: 'Suivi hebdomadaire',
      zoneIds: ['mfoundi-centre', 'mokolo-marche', 'bastos'],
      periodStart: DateTime(2026, 9, 8),
      periodEnd: DateTime(2026, 9, 15),
      createdAt: DateTime(2026, 9, 15),
    ),
    _demoAnalysis(
      id: 'analysis_demo_report_3',
      type: 'Bilan mensuel',
      zoneIds: [
        'mfoundi-centre',
        'biyem-assi',
        'bastos',
        'mokolo-marche',
        'ngoa-ekelle',
        'omnisports',
        'melen',
        'essos',
      ],
      periodStart: DateTime(2026, 8),
      periodEnd: DateTime(2026, 8, 31),
      createdAt: DateTime(2026, 8, 31),
    ),
    _demoAnalysis(
      id: 'analysis_demo_report_4',
      type: 'Synthèse trimestrielle',
      zoneIds: zones.map((zone) => zone.id).toList(growable: false),
      periodStart: DateTime(2026, 7),
      periodEnd: DateTime(2026, 9, 30),
      createdAt: DateTime(2026, 9, 28),
    ),
  ];

  late final List<AdminReport> reports = [
    _demoReport(
      id: 'report_1',
      analysisId: 'analysis_demo_default',
      title: 'Rapport municipal · Septembre',
      type: ReportType.synthesis,
      status: ReportStatus.ready,
      date: '22 sept. 2026',
      summary:
          'Bilan de performance et indicateurs d’assainissement pour le mois de septembre.',
    ),
    _demoReport(
      id: 'report_2',
      analysisId: 'analysis_demo_report_2',
      title: 'Suivi hebdomadaire Mfoundi',
      type: ReportType.tracking,
      status: ReportStatus.inProgress,
      date: '15 sept. 2026',
      summary:
          'Audit des points de friction et cadencement des camions bennes.',
    ),
    _demoReport(
      id: 'report_3',
      analysisId: 'analysis_demo_report_3',
      title: 'Bilan collecte · Août',
      type: ReportType.export,
      status: ReportStatus.archived,
      date: '31 août 2026',
      summary:
          'Archive définitive des volumes collectés au mois d’août 2026.',
    ),
    _demoReport(
      id: 'report_4',
      analysisId: 'analysis_demo_report_4',
      title: 'Synthèse propreté urbaine T3',
      type: ReportType.synthesis,
      status: ReportStatus.ready,
      date: '28 sept. 2026',
      summary: 'Synthèse consolidée du 3e trimestre 2026.',
    ),
  ];

  Analysis _demoAnalysis({
    required String id,
    required String type,
    required List<String> zoneIds,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DateTime createdAt,
  }) {
    final selectedZones = zones
        .where((zone) => zoneIds.contains(zone.id))
        .toList(growable: false);
    final scores = selectedZones.map((zone) => zone.score).toList();
    final sum = scores.fold<int>(0, (total, score) => total + score);
    final average = scores.isEmpty ? 0.0 : sum / scores.length;
    final indicators = AnalysisIndicators(
      totalPoints: scores.length,
      average: average,
      minimum: scores.isEmpty ? 0 : scores.reduce((a, b) => a < b ? a : b),
      maximum: scores.isEmpty ? 0 : scores.reduce((a, b) => a > b ? a : b),
      sum: sum,
      unit: 'pts',
    );
    return Analysis(
      id: id,
      type: type,
      periodStart: periodStart,
      periodEnd: periodEnd,
      zoneIds: List.unmodifiable(selectedZones.map((zone) => zone.id)),
      result:
          'Le score moyen des ${selectedZones.length} zones analysées est de '
          '${average.toStringAsFixed(1)} pts.',
      indicators: indicators,
      createdAt: createdAt,
    );
  }

  AdminReport _demoReport({
    required String id,
    required String analysisId,
    required String title,
    required ReportType type,
    required ReportStatus status,
    required String date,
    required String summary,
  }) {
    final analysis = analyses.firstWhere((item) => item.id == analysisId);
    final selectedZones = zones
        .where((zone) => analysis.zoneIds.contains(zone.id))
        .toList(growable: false);
    return AdminReport(
      id: id,
      analysisId: analysisId,
      title: title,
      type: type,
      status: status,
      date: date,
      zoneCount: analysis.indicators.totalPoints,
      zoneNames: List.unmodifiable(selectedZones.map((zone) => zone.name)),
      summary: summary,
      description: summary,
      createdAt: analysis.createdAt,
      indicators: analysis.indicators,
    );
  }

}
