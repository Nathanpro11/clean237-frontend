class Bac {
  final String id;
  final String code;
  final String etat;
  final double contenance;
  final double latitude;
  final double longitude;
  final String zoneNom;

  Bac({
    required this.id,
    required this.code,
    required this.etat,
    required this.contenance,
    required this.latitude,
    required this.longitude,
    required this.zoneNom,
  });

  factory Bac.fromJson(Map<String, dynamic> json) {
    final zone = json['zone'];
    return Bac(
      id: json['_id'] ?? '',
      code: json['code'] ?? '',
      etat: json['etat'] ?? 'Disponible',
      contenance: (json['contenance'] as num?)?.toDouble() ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      zoneNom: zone is Map ? (zone['nom'] ?? '').toString() : '',
    );
  }
}
