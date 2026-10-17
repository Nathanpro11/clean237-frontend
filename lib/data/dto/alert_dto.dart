class AlertDto {
  const AlertDto({
    required this.id,
    required this.titre,
    required this.sousTitre,
    required this.zoneId,
    required this.zoneNom,
    required this.date,
    required this.severite,
    required this.statut,
  });

  final String id;
  final String titre;
  final String sousTitre;
  final String zoneId;
  final String zoneNom;
  final DateTime date;
  final String severite;
  final String statut;

  factory AlertDto.fromJson(Map<String, dynamic> json) => AlertDto(
    id: (json['_id'] ?? '').toString(),
    titre: (json['titre'] ?? '').toString(),
    sousTitre: (json['sousTitre'] ?? '').toString(),
    zoneId: (json['zoneId'] ?? '').toString(),
    zoneNom: (json['zoneNom'] ?? '').toString(),
    date: DateTime.parse(json['date'].toString()).toUtc(),
    severite: (json['severite'] ?? 'info').toString(),
    statut: (json['statut'] ?? 'active').toString(),
  );
}
