class ZoneSimple {
  final String id;
  final String nom;

  ZoneSimple({required this.id, required this.nom});

  factory ZoneSimple.fromJson(Map<String, dynamic> json) =>
      ZoneSimple(id: json['_id'] ?? '', nom: (json['nom'] ?? '').toString());
}

class Bac {
  final String id;
  final String code;
  final String etat;
  final double longueur;
  final double largeur;
  final double contenance;
  final double latitude;
  final double longitude;
  final String zoneId;
  final String zoneNom;

  Bac({
    required this.id,
    required this.code,
    required this.etat,
    required this.longueur,
    required this.largeur,
    required this.contenance,
    required this.latitude,
    required this.longitude,
    required this.zoneId,
    required this.zoneNom,
  });

  factory Bac.fromJson(Map<String, dynamic> json) {
    final zone = json['zone'];
    return Bac(
      id: json['_id'] ?? '',
      code: json['code'] ?? '',
      etat: json['etat'] ?? 'Disponible',
      longueur: (json['longueur'] as num?)?.toDouble() ?? 0,
      largeur: (json['largeur'] as num?)?.toDouble() ?? 0,
      contenance: (json['contenance'] as num?)?.toDouble() ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      zoneId: zone is Map ? (zone['_id'] ?? '').toString() : (zone ?? '').toString(),
      zoneNom: zone is Map ? (zone['nom'] ?? '').toString() : '',
    );
  }
}
