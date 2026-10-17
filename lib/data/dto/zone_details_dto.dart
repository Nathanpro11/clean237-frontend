class ZoneEvolutionDto {
  const ZoneEvolutionDto({required this.date, required this.score});

  final DateTime date;
  final int score;

  factory ZoneEvolutionDto.fromJson(Map<String, dynamic> json) =>
      ZoneEvolutionDto(
        date: DateTime.parse(json['date'].toString()).toUtc(),
        score: (json['score'] as num).toInt(),
      );
}

class ZoneDetailsDto {
  const ZoneDetailsDto({
    required this.id,
    required this.nom,
    required this.score,
    required this.niveau,
    required this.evolution30Jours,
    required this.alertCount,
    required this.dataCount,
    this.evolutionPoints,
    this.derniereMiseAJour,
    this.interpretation,
    this.priorites = const [],
  });

  final String id;
  final String nom;
  final int score;
  final String niveau;
  final int? evolutionPoints;
  final DateTime? derniereMiseAJour;
  final List<ZoneEvolutionDto> evolution30Jours;
  final int alertCount;
  final int dataCount;
  final String? interpretation;
  final List<String> priorites;

  factory ZoneDetailsDto.fromJson(Map<String, dynamic> json) {
    final rawEvolution = json['evolution30Jours'] as List? ?? const [];
    final rawPriorities = json['priorites'] as List? ?? const [];
    return ZoneDetailsDto(
      id: (json['_id'] ?? '').toString(),
      nom: (json['nom'] ?? '').toString(),
      score: (json['score'] as num).toInt(),
      niveau: (json['niveau'] ?? '').toString(),
      evolutionPoints: (json['evolutionPoints'] as num?)?.toInt(),
      derniereMiseAJour: json['derniereMiseAJour'] == null
          ? null
          : DateTime.parse(json['derniereMiseAJour'].toString()).toUtc(),
      evolution30Jours: rawEvolution
          .map(
            (item) => ZoneEvolutionDto.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false),
      alertCount: (json['alertCount'] as num? ?? 0).toInt(),
      dataCount: (json['dataCount'] as num? ?? 0).toInt(),
      interpretation: json['interpretation']?.toString(),
      priorites: rawPriorities.map((item) => item.toString()).toList(),
    );
  }
}
