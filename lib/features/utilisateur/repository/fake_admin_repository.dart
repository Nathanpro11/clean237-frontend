import 'package:clean237_frontend/features/utilisateur/models/utilisateur_model.dart';
import 'package:clean237_frontend/features/utilisateur/repository/admin_repository.dart';

class FakeAdminRepository implements AdminRepository {
  final List<UtilisateurModel> _utilisateurs = [
    UtilisateurModel(
      id: 'u1',
      nom: 'Weezy Kolomso',
      email: 'weezy.kolomso@clean237.cm',
      telephone: '+237677000001',
      roleNom: 'citoyen',
      permissions: const ['creer_utilisateur'],
      estActif: true,
    ),
    UtilisateurModel(
      id: 'u2',
      nom: 'Néhémi Mbainadji',
      email: 'nehemi.mbainadji@clean237.cm',
      telephone: '+237677000002',
      matricule: 'AGT-237-001',
      zoneAffectee: 'Yaoundé VI',
      roleNom: 'agent',
      permissions: const ['creer_utilisateur', 'modifier_utilisateur'],
      estActif: true,
    ),
    UtilisateurModel(
      id: 'u3',
      nom: 'Aïcha Ngono',
      email: 'aicha.ngono@clean237.cm',
      telephone: '+237677000003',
      roleNom: 'citoyen',
      permissions: const [],
      estActif: true,
    ),
    UtilisateurModel(
      id: 'u4',
      nom: 'Paul Essomba',
      email: 'paul.essomba@clean237.cm',
      telephone: '+237677000004',
      matricule: 'AGT-237-014',
      zoneAffectee: 'Yaoundé VI',
      roleNom: 'agent',
      permissions: const ['modifier_utilisateur'],
      estActif: false,
    ),
    UtilisateurModel(
      id: 'u5',
      nom: 'Admin Yaoundé VI',
      email: 'admin@clean237.cm',
      telephone: '+237677000005',
      roleNom: 'admin',
      permissions: const [
        'creer_utilisateur',
        'modifier_utilisateur',
        'supprimer_utilisateur',
        'creer_role',
        'consulter_logs',
      ],
      estActif: true,
    ),
  ];

  @override
  Future<StatsAdmin> chargerStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const StatsAdmin(
      plaintesActives: 142,
      camionsActifs: 18,
      alertesCritiques: 5,
      trimestres: ['T1', 'T2', 'T3', 'T4'],
      tendanceParQuartier: {
        'Biyem-Assi': [32, 41, 38, 52],
        'Mendong': [21, 27, 35, 31],
        'Efoulan': [14, 19, 22, 29],
      },
    );
  }

  @override
  Future<List<UtilisateurModel>> chargerUtilisateurs() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_utilisateurs);
  }

  @override
  Future<UtilisateurModel> mettreAJourUtilisateur({
    required String id,
    bool? estActif,
    String? roleNom,
    List<String>? permissions,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _utilisateurs.indexWhere((u) => u.id == id);
    if (index == -1) {
      throw Exception('Utilisateur introuvable.');
    }

    final actuel = _utilisateurs[index];
    final modifie = UtilisateurModel(
      id: actuel.id,
      nom: actuel.nom,
      email: actuel.email,
      telephone: actuel.telephone,
      matricule: actuel.matricule,
      zoneAffectee: actuel.zoneAffectee,
      roleNom: roleNom ?? actuel.roleNom,
      permissions: permissions ?? actuel.permissions,
      estActif: estActif ?? actuel.estActif,
    );
    _utilisateurs[index] = modifie;
    return modifie;
  }

  @override
  Future<String> dernierIpAudite(String utilisateurId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return '192.168.88.95';
  }
}