import 'package:clean237_frontend/features/utilisateur/models/utilisateur_model.dart';
import 'package:clean237_frontend/features/utilisateur/repository/admin_repository.dart';
import 'package:clean237_frontend/features/utilisateur/repository/utilisateurs_store.dart';

/// Implémentation FACTICE d'AdminRepository. Les comptes viennent du même
/// UtilisateursStore que FakeAuthRepository : rien n'est dupliqué ni désynchronisé.
class FakeAdminRepository implements AdminRepository {
  final UtilisateursStore _store;

  FakeAdminRepository(this._store);

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
    return _store.mettreAJourDroits(
      id: id,
      estActif: estActif,
      roleNom: roleNom,
      permissions: permissions,
    );
  }

  @override
  Future<String> dernierIpAudite(String utilisateurId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return '192.168.88.95';
  }
}