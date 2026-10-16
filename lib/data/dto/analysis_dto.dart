class AnalysisTypeIndicatorDto {
  const AnalysisTypeIndicatorDto({
    required this.count,
    required this.moyenne,
    required this.minimum,
    required this.maximum,
    required this.somme,
    this.unite,
  });

  final int count;
  final num moyenne;
  final num minimum;
  final num maximum;
  final num somme;
  final String? unite;

  factory AnalysisTypeIndicatorDto.fromJson(Map<String, dynamic> json) =>
      AnalysisTypeIndicatorDto(
        count: (json['count'] as num? ?? 0).toInt(),
        moyenne: json['moyenne'] as num? ?? 0,
        minimum: json['minimum'] as num? ?? 0,
        maximum: json['maximum'] as num? ?? 0,
        somme: json['somme'] as num? ?? 0,
        unite: json['unite']?.toString(),
      );
}

class AnalysisIndicatorsDto {
  const AnalysisIndicatorsDto({
    required this.totalPoints,
    required this.parType,
  });

  final int totalPoints;
  final Map<String, AnalysisTypeIndicatorDto> parType;

  factory AnalysisIndicatorsDto.fromJson(Map<String, dynamic> json) {
    final rawByType = json['parType'] is Map
        ? Map<String, dynamic>.from(json['parType'] as Map)
        : const <String, dynamic>{};
    return AnalysisIndicatorsDto(
      totalPoints: (json['totalPoints'] as num? ?? 0).toInt(),
      parType: rawByType.map(
        (key, value) => MapEntry(
          key,
          AnalysisTypeIndicatorDto.fromJson(
            Map<String, dynamic>.from(value as Map),
          ),
        ),
      ),
    );
  }
}

class AnalysisDto {
  const AnalysisDto({
    required this.id,
    required this.type,
    required this.periode,
    required this.resultat,
    required this.indicateurs,
    required this.createdAt,
    this.zoneId,
    this.zoneNom,
    this.updatedAt,
    this.donneesUtilisees = const [],
  });

  final String id;
  final String type;
  final String? zoneId;
  final String? zoneNom;
  final Map<String, dynamic> periode;
  final String resultat;
  final AnalysisIndicatorsDto indicateurs;
  final List<String> donneesUtilisees;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory AnalysisDto.fromJson(Map<String, dynamic> json) {
    final rawPeriod = Map<String, dynamic>.from(json['periode'] as Map);
    final rawIndicators = Map<String, dynamic>.from(
      json['indicateurs'] as Map? ?? const {},
    );
    final rawDataUsed = json['donneesUtilisees'] as List? ?? const [];
    return AnalysisDto(
      id: (json['_id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      zoneId: json['zoneId']?.toString(),
      zoneNom: json['zoneNom']?.toString(),
      periode: rawPeriod,
      resultat: (json['resultat'] ?? '').toString(),
      indicateurs: AnalysisIndicatorsDto.fromJson(rawIndicators),
      donneesUtilisees: rawDataUsed.map((value) => value.toString()).toList(),
      createdAt: DateTime.parse(json['createdAt'].toString()).toUtc(),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'].toString()).toUtc(),
    );
  }
}
