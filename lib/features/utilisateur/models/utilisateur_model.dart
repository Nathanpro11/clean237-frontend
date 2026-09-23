class UtilisateurModel {
  final String id;
  final String nom;
  final String email;
  final String telephone;
  final String? matricule;
  final String? zoneAffectee;
  final String roleNom;
  final List<String> permissions;
  final bool estActif;

  UtilisateurModel({
    required this.id,
    required this.nom,
    required this.email,
    required this.telephone,
    this.matricule,
    this.zoneAffectee,
    required this.roleNom,
    required this.permissions,
    required this.estActif,
  });

  // Désérialisation du flux JSON envoyé par votre backend Node.js (port 3000)
  factory UtilisateurModel.fromJson(Map<String, dynamic> json) {
    final roleData = json['roleId'] as Map<String, dynamic>? ?? {};
    final roleName = roleData['nom'] as String? ?? 'citoyen';
    
    final permissionsList = (roleData['permissionsIds'] as List? ?? [])
        .map((p) => p is Map ? (p['nom'] as String? ?? '') : p.toString())
        .where((nom) => nom.isNotEmpty)
        .toList();

    return UtilisateurModel(
      id: json['_id'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      email: json['email'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
      matricule: json['matricule'] as String?,
      zoneAffectee: json['zoneAffectee'] as String?,
      roleNom: roleName,
      permissions: permissionsList,
      estActif: json['estActif'] as bool? ?? true,
    );
  }
}
