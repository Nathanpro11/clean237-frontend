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

  // 🆕 Fonctionnalités de base du module Utilisateur
  Future<AuthResult> modifierProfil({
    required String nom,
    required String telephone,
  });

  Future<AuthResult> changerMotDePasse({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
  });
}