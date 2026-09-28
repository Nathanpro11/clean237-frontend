import 'package:clean237_frontend/features/utilisateur/models/utilisateur_model.dart';

class StatsAdmin {
  final int plaintesActives;
  final int camionsActifs;
  final int alertesCritiques;
  final List<String> trimestres;
  final Map<String, List<double>> tendanceParQuartier;

  const StatsAdmin({
    required this.plaintesActives,
    required this.camionsActifs,
    required this.alertesCritiques,
    required this.trimestres,
    required this.tendanceParQuartier,
  });
}

/// Contrat de la supervision municipale (Super-Admin).
/// FakeAdminRepository maintenant, ApiAdminRepository quand le backend sera prêt.
abstract class AdminRepository {
  Future<StatsAdmin> chargerStats();

  Future<List<UtilisateurModel>> chargerUtilisateurs();

  /// Suppression logique (estActif), changement de rôle et de permissions.
  Future<UtilisateurModel> mettreAJourUtilisateur({
    required String id,
    bool? estActif,
    String? roleNom,
    List<String>? permissions,
  });

  Future<String> dernierIpAudite(String utilisateurId);
}