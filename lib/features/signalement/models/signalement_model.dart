class Signalement {
  final String id;
  final String description;
  final String statut;
  final String photoUrl;
  final String quartier;
  final String? precision;
  final double? latitude;
  final double? longitude;
  final String? motifRejet;
  final bool archive;
  final String citoyenId;
  final String? agentId;
  final String dateCreation;

  Signalement({
    required this.id,
    required this.description,
    required this.statut,
    required this.photoUrl,
    required this.quartier,
    this.precision,
    this.latitude,
    this.longitude,
    this.motifRejet,
    required this.archive,
    required this.citoyenId,
    this.agentId,
    required this.dateCreation,
  });

  bool get aUnePosition => latitude != null && longitude != null;

  factory Signalement.fromJson(Map<String, dynamic> json) {
    return Signalement(
      id: json['_id'] ?? '',
      description: json['description'] ?? '',
      statut: json['statut'] ?? 'en_attente',
      photoUrl: json['photoUrl'] ?? '',
      quartier: json['quartier'] ?? '',
      precision: json['precision'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      motifRejet: json['motifRejet'],
      archive: json['archive'] ?? false,
      citoyenId: json['citoyenId'] ?? '',
      agentId: json['agentId'],
      dateCreation: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'description': description,
      'citoyenId': citoyenId,
      'photoUrl': photoUrl,
      'quartier': quartier,
    };
    if (precision != null && precision!.trim().isNotEmpty) {
      data['precision'] = precision!;
    }
    if (latitude != null && longitude != null) {
      data['latitude'] = latitude;
      data['longitude'] = longitude;
    }
    return data;
  }
}
