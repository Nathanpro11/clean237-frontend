// ⚠️ CE FICHIER VA DANS : lib/features/utilisateur/repository/auth_repository.dart
// Contient AuthResult + l'interface AuthRepository (connexion/inscription/profil/réinitialisation).
// NE PAS CONFONDRE avec admin_repository.dart (StatsAdmin + AdminRepository).

import 'package:clean237_frontend/features/utilisateur/models/utilisateur_model.dart';

class AuthResult {
  final bool succes;
  final String? messageErreur;
  final bool estBloqueAntiBruteforce;
  final String? token;
  final UtilisateurModel? utilisateur;

  AuthResult({
    required this.succes,
    this.messageErreur,
    this.estBloqueAntiBruteforce = false,
    this.token,
    this.utilisateur,
  });
}

abstract class AuthRepository {
  Future<AuthResult> login(String email, String motDepasse);

  Future<AuthResult> inscrireUnUtilisateur({
    required String nom,
    required String email,
    required String telephone,
    required String motDepasse,
    required String profil,
    String? matricule,
    String? zoneAffectee,
  });

  Future<AuthResult> modifierProfil({
    required String nom,
    required String telephone,
  });

  Future<AuthResult> changerMotDePasse({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
  });

  /// Étape 1 du "mot de passe oublié" : le serveur envoie un code par e-mail
  /// (réponse identique que le compte existe ou non).
  Future<AuthResult> demanderCodeReinitialisation({required String email});

  /// Étape 2 : valide le code reçu et définit le nouveau mot de passe.
  Future<AuthResult> confirmerReinitialisation({
    required String email,
    required String code,
    required String nouveauMotDePasse,
  });
}