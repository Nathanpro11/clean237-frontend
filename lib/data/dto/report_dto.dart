class ReportZoneDto {
  const ReportZoneDto({required this.id, required this.nom});

  final String id;
  final String nom;

  factory ReportZoneDto.fromJson(Map<String, dynamic> json) => ReportZoneDto(
    id: (json['_id'] ?? '').toString(),
    nom: (json['nom'] ?? '').toString(),
  );
}

class ReportDto {
  const ReportDto({
    required this.id,
    required this.titre,
    required this.analyseId,
    required this.type,
    required this.statut,
    required this.format,
    required this.zones,
    required this.statistiques,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  final String id;
  final String titre;
  final String? description;
  final dynamic analyseId;
  final String type;
  final String statut;
  final String format;
  final List<ReportZoneDto> zones;
  final Map<String, dynamic> statistiques;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ReportDto.fromJson(Map<String, dynamic> json) {
    final rawZones = json['zones'] as List? ?? const [];
    final rawStats = json['statistiques'] is Map
        ? Map<String, dynamic>.from(json['statistiques'] as Map)
        : const <String, dynamic>{};
    return ReportDto(
      id: (json['_id'] ?? '').toString(),
      titre: (json['titre'] ?? '').toString(),
      description: json['description']?.toString(),
      analyseId: json['analyseId'],
      type: (json['type'] ?? '').toString(),
      statut: (json['statut'] ?? '').toString(),
      format: (json['format'] ?? '').toString(),
      zones: rawZones
          .map(
            (item) => ReportZoneDto.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false),
      statistiques: rawStats,
      createdAt: DateTime.parse(json['createdAt'].toString()).toUtc(),
      updatedAt: DateTime.parse(
        (json['updatedAt'] ?? json['createdAt']).toString(),
      ).toUtc(),
    );
  }

  String? get analysisId => analyseId is Map
      ? (analyseId['_id'] ?? analyseId['id'])?.toString()
      : analyseId?.toString();
}
