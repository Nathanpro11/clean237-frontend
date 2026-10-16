class EnvironmentalDataDto {
  const EnvironmentalDataDto({
    required this.id,
    required this.type,
    required this.zoneId,
    required this.valeur,
    this.unite,
    required this.date,
    this.source,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String type;
  final String zoneId;
  final num valeur;
  final String? unite;
  final DateTime date;
  final String? source;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory EnvironmentalDataDto.fromJson(Map<String, dynamic> json) {
    return EnvironmentalDataDto(
      id: (json['_id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      zoneId: (json['zoneId'] ?? '').toString(),
      valeur: (json['valeur'] as num?) ?? 0,
      unite: json['unite']?.toString(),
      date: DateTime.parse(json['date'].toString()).toUtc(),
      source: json['source']?.toString(),
      description: json['description']?.toString(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'].toString()).toUtc(),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'].toString()).toUtc(),
    );
  }
}
