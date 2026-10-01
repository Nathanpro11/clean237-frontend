import 'package:clean237_frontend/features/utilisateur/repository/auth_repository.dart';
import 'package:clean237_frontend/features/utilisateur/repository/utilisateurs_store.dart';
import 'package:clean237_frontend/utils/jwt_helper.dart';

/// Implémentation FACTICE d'AuthRepository (sans backend).
/// Lit et écrit dans UtilisateursStore, partagé avec FakeAdminRepository :
/// un compte créé ici est visible dans la gestion admin, et un compte
/// désactivé par l'admin ne peut plus se connecter ici.
class FakeAuthRepository implements AuthRepository {
  final UtilisateursStore _store;

  FakeAuthRepository(this._store);

  int _tentativesEchouees = 0;
  String? _emailConnecte;

  @override
  Future<AuthResult> login(String email, String motDepasse) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (_tentativesEchouees >= 3) {
      return AuthResult(
        succes: false,
        estBloqueAntiBruteforce: true,
        messageErreur:
            'Trop de tentatives échouées. Compte temporairement bloqué (simulation).',
      );
    }

    final compte = _store.trouverParEmail(email);
    final motDePasseAttendu = _store.motDePassePour(email);

    if (compte != null && motDePasseAttendu != null && motDepasse.trim() == motDePasseAttendu) {
      if (!compte.estActif) {
        return AuthResult(succes: false, messageErreur: 'Ce compte est désactivé.');
      }

      _tentativesEchouees = 0;
      _emailConnecte = compte.email;

      final token = JwtHelper.creerTokenFactice({
        'id': compte.id,
        'email': compte.email,
        'role': {'nom': compte.roleNom, 'permissionsIds': compte.permissions},
        'exp': DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
      });

      return AuthResult(succes: true, token: token, utilisateur: compte);
    }

    _tentativesEchouees++;
    return AuthResult(succes: false, messageErreur: 'Identifiants invalides.');
  }

  @override
  Future<AuthResult> inscrireUnUtilisateur({
    required String nom,
    required String email,
    required String telephone,
    required String motDepasse,
    required String profil,
    String? matricule,
    String? zoneAffectee,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (_store.emailExiste(email)) {
      return AuthResult(succes: false, messageErreur: 'Cet email est déjà utilisé.');
    }

    final nouveauCompte = _store.creerCompte(
      nom: nom,
      email: email,
      telephone: telephone,
      motDepasse: motDepasse,
      roleNom: profil,
      matricule: matricule,
      zoneAffectee: zoneAffectee,
    );

    return AuthResult(succes: true, utilisateur: nouveauCompte);
  }

  @override
  Future<AuthResult> modifierProfil({
    required String nom,
    required String telephone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final email = _emailConnecte;
    if (email == null) {
      return AuthResult(succes: false, messageErreur: 'Aucun utilisateur connecté.');
    }

    if (nom.trim().isEmpty) {
      return AuthResult(succes: false, messageErreur: 'Le nom ne peut pas être vide.');
    }

    final modifie = _store.mettreAJourProfil(email: email, nom: nom, telephone: telephone);
    return AuthResult(succes: true, utilisateur: modifie);
  }

  @override
  Future<AuthResult> changerMotDePasse({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final email = _emailConnecte;
    if (email == null) {
      return AuthResult(succes: false, messageErreur: 'Aucun utilisateur connecté.');
    }

    if (nouveauMotDePasse.trim().length < 6) {
      return AuthResult(succes: false, messageErreur: '6 caractères minimum requis.');
    }

    final ok = _store.changerMotDePasse(
      email: email,
      ancien: ancienMotDePasse,
      nouveau: nouveauMotDePasse,
    );

    if (!ok) {
      return AuthResult(succes: false, messageErreur: 'Ancien mot de passe incorrect.');
    }

    return AuthResult(succes: true);
  }
}