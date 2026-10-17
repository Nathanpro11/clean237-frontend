import 'package:clean237_frontend/features/utilisateur/models/utilisateur_model.dart';
import 'package:clean237_frontend/features/utilisateur/repository/admin_repository.dart';
import 'package:clean237_frontend/features/utilisateur/repository/utilisateurs_store.dart';

/// Implémentation FACTICE d'AdminRepository (mode hors ligne). Les comptes viennent du
/// même UtilisateursStore que FakeAuthRepository : rien n'est dupliqué ni désynchronisé.
class FakeAdminRepository implements AdminRepository {
  final UtilisateursStore _store;

  FakeAdminRepository(this._store);

  @override
  Future<StatsAdmin> chargerStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final tous = _store.listerTous();
    final actifs = tous.where((u) => u.estActif).toList();

    return StatsAdmin(
      totalComptes: tous.length,
      comptesActifs: actifs.length,
      citoyensActifs: actifs.where((u) => u.roleNom == 'citoyen').length,
      agentsActifs: actifs.where((u) => u.roleNom == 'agent').length,
      connexionsAujourdHui: 0,
      nouveauxInscrits7j: 0,
    );
  }

  @override
  Future<List<UtilisateurModel>> chargerUtilisateurs() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _store.listerTous();
  }

  @override
  Future<UtilisateurModel> mettreAJourUtilisateur({
    required String id,
    bool? estActif,
    String? roleNom,
    List<String>? permissions,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return await _store.mettreAJourDroits(
      id: id,
      estActif: estActif,
      roleNom: roleNom,
      permissions: permissions,
    );
  }

  @override
  Future<UtilisateurModel> creerUtilisateur({
    required String nom,
    required String email,
    required String telephone,
    required String motDepasse,
    required String roleNom,
    String? matricule,
    String? zoneAffectee,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_store.emailExiste(email)) {
      throw Exception('Cet email est déjà utilisé.');
    }

    return await _store.creerCompte(
      nom: nom,
      email: email,
      telephone: telephone,
      motDepasse: motDepasse,
      roleNom: roleNom,
      matricule: matricule,
      zoneAffectee: zoneAffectee,
    );
  }

  @override
  Future<String> dernierIpAudite(String utilisateurId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return '192.168.88.95';
  }
}