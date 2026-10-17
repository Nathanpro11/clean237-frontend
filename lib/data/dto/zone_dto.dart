class ZoneDto {
  const ZoneDto({
    required this.id,
    required this.nom,
  });

  final String id;
  final String nom;

  factory ZoneDto.fromJson(Map<String, dynamic> json) {
    return ZoneDto(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      nom: (json['nom'] ?? '').toString(),
    );
  }
}
