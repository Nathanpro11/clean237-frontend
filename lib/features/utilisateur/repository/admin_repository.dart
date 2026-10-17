// ⚠️ CE FICHIER VA DANS : lib/features/utilisateur/repository/admin_repository.dart
// Contient StatsAdmin + l'interface AdminRepository (dashboard, comptes, RBAC).
// NE PAS CONFONDRE avec auth_repository.dart (AuthResult + AuthRepository).

import 'package:clean237_frontend/features/utilisateur/models/utilisateur_model.dart';

/// Statistiques RÉELLES de supervision (calculées en base par le backend).
class StatsAdmin {
  final int totalComptes;
  final int comptesActifs;
  final int citoyensActifs;
  final int agentsActifs;
  final int connexionsAujourdHui;
  final int nouveauxInscrits7j;
  final int alertesActives;
  final int alertesTraitees;

  const StatsAdmin({
    required this.totalComptes,
    required this.comptesActifs,
    required this.citoyensActifs,
    required this.agentsActifs,
    required this.connexionsAujourdHui,
    required this.nouveauxInscrits7j,
    this.alertesActives = 0,
    this.alertesTraitees = 0,
  });
}

/// Contrat de la supervision municipale (Super-Admin).
/// FakeAdminRepository (hors ligne) ou ApiAdminRepository (backend).
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

  /// Création directe d'un compte depuis le panneau admin.
  Future<UtilisateurModel> creerUtilisateur({
    required String nom,
    required String email,
    required String telephone,
    required String motDepasse,
    required String roleNom,
    String? matricule,
    String? zoneAffectee,
  });

  Future<String> dernierIpAudite(String utilisateurId);
}