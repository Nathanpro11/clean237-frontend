class Signalement {
  final String id;
  final String description;
  final String statut;
  final String photoUrl;
  final String quartier;
  final String? precision;
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
    this.motifRejet,
    required this.archive,
    required this.citoyenId,
    this.agentId,
    required this.dateCreation,
  });

  factory Signalement.fromJson(Map<String, dynamic> json) {
    return Signalement(
      id: json['_id'] ?? '',
      description: json['description'] ?? '',
      statut: json['statut'] ?? 'en_attente',
      photoUrl: json['photoUrl'] ?? '',
      quartier: json['quartier'] ?? '',
      precision: json['precision'],
      motifRejet: json['motifRejet'],
      archive: json['archive'] ?? false,
      citoyenId: json['citoyenId'] ?? '',
      agentId: json['agentId'],
      dateCreation: json['dateCreation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'description': description,
      'citoyenId': citoyenId,
      'photoUrl': photoUrl,
      'quartier': quartier,
    };
    if (precision != null && precision!.trim().isNotEmpty) {
      data['precision'] = precision!;
    }
    return data;
  }
}
