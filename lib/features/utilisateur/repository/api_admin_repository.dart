import 'package:clean237_frontend/features/utilisateur/models/utilisateur_model.dart';
import 'package:clean237_frontend/features/utilisateur/repository/admin_repository.dart';
import 'package:clean237_frontend/utils/api_client.dart';

/// Implémentation réelle d'AdminRepository (backend Express).
class ApiAdminRepository implements AdminRepository {
  @override
  Future<StatsAdmin> chargerStats() async {
    final data = await ApiClient.get('/utilisateurs/dashboard/stats/${ApiClient.userId}');
    final ind = (data['statistiques']?['Indicateurs'] ?? <String, dynamic>{}) as Map<String, dynamic>;
    int n(String cle) => (ind[cle] as num?)?.toInt() ?? 0;

    return StatsAdmin(
      totalComptes: n('totalComptes'),
      comptesActifs: n('comptesActifs'),
      citoyensActifs: n('citoyensActifs'),
      agentsActifs: n('agentsActifs'),
      connexionsAujourdHui: n('connexionsAujourdhui'),
      nouveauxInscrits7j: n('nouveauxInscrits7j'),
      alertesActives: n('alertesActives'),
      alertesTraitees: n('alertesTraitees'),
    );
  }

  @override
  Future<List<UtilisateurModel>> chargerUtilisateurs() async {
    final data = await ApiClient.get('/utilisateurs/list', query: {'limit': '100'});
    return (data['data'] as List)
        .map((j) => UtilisateurModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<UtilisateurModel> mettreAJourUtilisateur({
    required String id,
    bool? estActif,
    String? roleNom,
    List<String>? permissions, // les permissions appartiennent au rôle : ignorées ici
  }) async {
    Map<String, dynamic>? derniere;

    if (roleNom != null) {
      final r = await ApiClient.put('/utilisateurs/roles/assign-to-user/$id', {'role': roleNom});
      derniere = r['data'] as Map<String, dynamic>;
    }
    if (estActif != null) {
      final r = await ApiClient.put('/utilisateurs/admin/statut/$id', {'estActif': estActif});
      derniere = r['data'] as Map<String, dynamic>;
    }
    if (derniere == null) throw ApiException('Aucune modification à enregistrer.');
    return UtilisateurModel.fromJson(derniere);
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
    final data = await ApiClient.post('/utilisateurs/admin/create', {
      'nom': nom,
      'email': email,
      'telephone': telephone,
      'motDepasse': motDepasse,
      'profil': roleNom,
      if (matricule != null) 'matricule': matricule,
      if (zoneAffectee != null) 'zoneAffectee': zoneAffectee,
    });
    return UtilisateurModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  @override
  Future<String> dernierIpAudite(String utilisateurId) async {
    try {
      final data = await ApiClient.get('/utilisateurs/historique/$utilisateurId');
      final logs = data['historique'] as List? ?? [];
      if (logs.isEmpty) return 'aucune activité';
      return (logs.first as Map<String, dynamic>)['ipAddress'] as String? ?? 'inconnue';
    } catch (_) {
      return 'indisponible';
    }
  }
}