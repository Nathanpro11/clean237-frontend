import 'package:flutter/material.dart';
import 'package:clean237_frontend/features/utilisateur/models/utilisateur_model.dart';
import 'package:clean237_frontend/features/utilisateur/repository/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _repository;

  AuthController(this._repository);

  UtilisateurModel? _utilisateurConnecte;
  String? _tokenJwt;
  bool _estEnCoursDeChargement = false;
  String? _messageErreur;
  bool _estBloqueAntiBruteforce = false;

  UtilisateurModel? get utilisateur => _utilisateurConnecte;
  String? get token => _tokenJwt;
  bool get estEnCoursDeChargement => _estEnCoursDeChargement;
  String? get messageErreur => _messageErreur;
  bool get estBloqueAntiBruteforce => _estBloqueAntiBruteforce;

  void _setChargement(bool valeur) {
    _estEnCoursDeChargement = valeur;
    notifyListeners();
  }

  Future<bool> login(String email, String motDepasse) async {
    _setChargement(true);
    _messageErreur = null;
    _estBloqueAntiBruteforce = false;

    final resultat = await _repository.login(email, motDepasse);

    _tokenJwt = resultat.token;
    _utilisateurConnecte = resultat.utilisateur;
    _messageErreur = resultat.messageErreur;
    _estBloqueAntiBruteforce = resultat.estBloqueAntiBruteforce;
    _setChargement(false);
    return resultat.succes;
  }

  Future<bool> inscrireUnUtilisateur({
    required String nom,
    required String email,
    required String telephone,
    required String motDepasse,
    required String profil,
    String? matricule,
    String? zoneAffectee,
  }) async {
    _setChargement(true);
    _messageErreur = null;

    final resultat = await _repository.inscrireUnUtilisateur(
      nom: nom,
      email: email,
      telephone: telephone,
      motDepasse: motDepasse,
      profil: profil,
      matricule: matricule,
      zoneAffectee: zoneAffectee,
    );

    _messageErreur = resultat.messageErreur;
    _setChargement(false);
    return resultat.succes;
  }

  // 🆕 Modifier les infos du profil (nom, téléphone)
  Future<bool> modifierProfil({
    required String nom,
    required String telephone,
  }) async {
    _setChargement(true);
    _messageErreur = null;

    final resultat = await _repository.modifierProfil(nom: nom, telephone: telephone);

    if (resultat.succes && resultat.utilisateur != null) {
      _utilisateurConnecte = resultat.utilisateur;
    }
    _messageErreur = resultat.messageErreur;
    _setChargement(false);
    return resultat.succes;
  }

  // 🆕 Changer le mot de passe
  Future<bool> changerMotDePasse({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
  }) async {
    _setChargement(true);
    _messageErreur = null;

    final resultat = await _repository.changerMotDePasse(
      ancienMotDePasse: ancienMotDePasse,
      nouveauMotDePasse: nouveauMotDePasse,
    );

    _messageErreur = resultat.messageErreur;
    _setChargement(false);
    return resultat.succes;
  }

  void logout() {
    _utilisateurConnecte = null;
    _tokenJwt = null;
    _messageErreur = null;
    _estBloqueAntiBruteforce = false;
    notifyListeners();
  }
}