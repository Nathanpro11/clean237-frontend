import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:clean237_frontend/features/utilisateur/models/utilisateur_model.dart';
import 'package:clean237_frontend/features/utilisateur/repository/auth_repository.dart';
import 'package:clean237_frontend/utils/api_client.dart';
import 'package:clean237_frontend/utils/jwt_helper.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _repository;

  AuthController(this._repository);

  static const bool _horsLigne = bool.fromEnvironment('OFFLINE');
  static const String _cleToken = 'jwt_clean237';
  final FlutterSecureStorage _stockage = const FlutterSecureStorage();

  UtilisateurModel? _utilisateurConnecte;
  String? _tokenJwt;
  String? _role;
  bool _estEnCoursDeChargement = false;
  String? _messageErreur;
  bool _estBloqueAntiBruteforce = false;

  UtilisateurModel? get utilisateur => _utilisateurConnecte;
  String? get token => _tokenJwt;

  /// Rôle résolu depuis le payload du JWT ("citoyen", "agent" ou "admin").
  String? get role => _role;
  bool get estAdmin => _role == 'admin';

  /// Session valide : utilisateur chargé et token JWT non expiré.
  bool get estConnecte =>
      _utilisateurConnecte != null && _tokenJwt != null && !JwtHelper.estExpire(_tokenJwt);

  bool get estEnCoursDeChargement => _estEnCoursDeChargement;
  String? get messageErreur => _messageErreur;
  bool get estBloqueAntiBruteforce => _estBloqueAntiBruteforce;

  void _setChargement(bool valeur) {
    _estEnCoursDeChargement = valeur;
    notifyListeners();
  }

  Future<void> _effacerJetonStocke() async {
    try {
      await _stockage.delete(key: _cleToken);
    } catch (_) {}
  }

  /// Au démarrage : relit le jeton stocké, vérifie son expiration puis appelle /me.
  /// Retourne true si la session est restaurée. Jeton expiré ou refusé (401) : il est effacé.
  Future<bool> restaurerSession() async {
    if (_horsLigne) return false;
    try {
      final token = await _stockage.read(key: _cleToken);
      if (token == null) return false;

      final idUser = JwtHelper.decoderPayload(token)?['idUser']?.toString();
      if (JwtHelper.estExpire(token) || idUser == null) {
        await _effacerJetonStocke();
        return false;
      }

      ApiClient.ouvrirSession(token: token, userId: idUser);
      final data = await ApiClient.get('/utilisateurs/me');
      final utilisateur = UtilisateurModel.fromJson(data as Map<String, dynamic>);

      _tokenJwt = token;
      _utilisateurConnecte = utilisateur;
      _role = JwtHelper.extraireRole(token) ?? utilisateur.roleNom;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      ApiClient.fermerSession();
      // 401 : jeton refusé. Autre erreur (réseau) : on garde le jeton pour la prochaine fois.
      if (e.statusCode == 401) await _effacerJetonStocke();
      return false;
    } catch (_) {
      ApiClient.fermerSession();
      return false;
    }
  }

  Future<bool> login(String email, String motDepasse) async {
    _setChargement(true);
    _messageErreur = null;
    _estBloqueAntiBruteforce = false;

    final resultat = await _repository.login(email, motDepasse);

    _tokenJwt = resultat.token;
    _utilisateurConnecte = resultat.utilisateur;
    // Le rôle vient du token ; à défaut, du profil renvoyé.
    _role = JwtHelper.extraireRole(resultat.token) ?? resultat.utilisateur?.roleNom;
    _messageErreur = resultat.messageErreur;
    _estBloqueAntiBruteforce = resultat.estBloqueAntiBruteforce;

    if (resultat.succes && resultat.token != null && !_horsLigne) {
      try {
        await _stockage.write(key: _cleToken, value: resultat.token);
      } catch (_) {}
    }

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

  /// "Mot de passe oublié", étape 1 : envoie un code par e-mail.
  /// Retourne null si tout va bien, sinon le message d'erreur à afficher.
  /// N'affecte pas l'état de l'écran de connexion (le dialogue gère son propre état).
  Future<String?> demanderCodeReinitialisation(String email) async {
    final resultat = await _repository.demanderCodeReinitialisation(email: email);
    return resultat.succes ? null : (resultat.messageErreur ?? "Impossible d'envoyer le code.");
  }

  /// "Mot de passe oublié", étape 2 : code reçu + nouveau mot de passe.
  /// Retourne null si le mot de passe a été réinitialisé, sinon le message d'erreur.
  Future<String?> confirmerReinitialisation({
    required String email,
    required String code,
    required String nouveauMotDePasse,
  }) async {
    final resultat = await _repository.confirmerReinitialisation(
      email: email,
      code: code,
      nouveauMotDePasse: nouveauMotDePasse,
    );
    return resultat.succes ? null : (resultat.messageErreur ?? 'La réinitialisation a échoué.');
  }

  void logout() {
    ApiClient.fermerSession();
    _effacerJetonStocke();
    _utilisateurConnecte = null;
    _tokenJwt = null;
    _role = null;
    _messageErreur = null;
    _estBloqueAntiBruteforce = false;
    notifyListeners();
  }
}
