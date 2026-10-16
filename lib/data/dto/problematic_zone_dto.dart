class ProblematicZoneDto {
  const ProblematicZoneDto({
    required this.zoneId,
    required this.nom,
    required this.score,
    required this.niveau,
    required this.details,
  });

  final String zoneId;
  final String nom;
  final int score;
  final String niveau;
  final Map<String, dynamic> details;

  factory ProblematicZoneDto.fromJson(Map<String, dynamic> json) {
    return ProblematicZoneDto(
      zoneId: (json['zoneId'] ?? '').toString(),
      nom: (json['nom'] ?? '').toString(),
      score: (json['score'] as num? ?? 0).toInt(),
      niveau: (json['niveau'] ?? 'normal').toString(),
      details: Map<String, dynamic>.from(json['details'] as Map? ?? const {}),
    );
  }
}
