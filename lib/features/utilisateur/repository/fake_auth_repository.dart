import 'package:clean237_frontend/features/utilisateur/repository/auth_repository.dart';
import 'package:clean237_frontend/features/utilisateur/repository/utilisateurs_store.dart';
import 'package:clean237_frontend/features/utilisateur/utils/jwt_helper.dart';

/// Implémentation FACTICE d'AuthRepository (sans backend).
/// Lit et écrit dans UtilisateursStore, partagé avec FakeAdminRepository :
/// un compte créé ici est visible dans la gestion admin, et un compte
/// désactivé par l'admin ne peut plus se connecter ici.
class FakeAuthRepository implements AuthRepository {
  final UtilisateursStore _store;

  FakeAuthRepository(this._store);

  // 🔐 Anti-bruteforce PAR COMPTE : chaque email a son propre compteur
  // d'échecs, pour ne jamais bloquer un compte à cause des tentatives
  // ratées sur un autre.
  final Map<String, int> _tentativesEchoueesParEmail = {};
  static const int _seuilBlocage = 3;

  String? _emailConnecte;

  @override
  Future<AuthResult> login(String email, String motDepasse) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final emailNormalise = email.trim().toLowerCase();
    final tentatives = _tentativesEchoueesParEmail[emailNormalise] ?? 0;

    if (tentatives >= _seuilBlocage) {
      return AuthResult(
        succes: false,
        estBloqueAntiBruteforce: true,
        messageErreur:
            'Trop de tentatives échouées sur ce compte. Réessayez plus tard (simulation).',
      );
    }

    final compte = _store.trouverParEmail(emailNormalise);
    final motDePasseAttendu = _store.motDePassePour(emailNormalise);

    if (compte != null && motDePasseAttendu != null && motDepasse.trim() == motDePasseAttendu) {
      if (!compte.estActif) {
        return AuthResult(succes: false, messageErreur: 'Ce compte est désactivé.');
      }

      _tentativesEchoueesParEmail.remove(emailNormalise);
      _emailConnecte = compte.email;

      final token = JwtHelper.creerTokenFactice({
        'id': compte.id,
        'email': compte.email,
        'role': {'nom': compte.roleNom, 'permissionsIds': compte.permissions},
        'exp': DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
      });

      return AuthResult(succes: true, token: token, utilisateur: compte);
    }

    // On n'incrémente le compteur que si le compte existe réellement :
    // taper un email au hasard ne doit pas pouvoir bloquer un vrai compte.
    if (compte != null) {
      _tentativesEchoueesParEmail[emailNormalise] = tentatives + 1;
    }

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

    final nouveauCompte = await _store.creerCompte(
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

    final modifie = await _store.mettreAJourProfil(email: email, nom: nom, telephone: telephone);
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

    final ok = await _store.changerMotDePasse(
      email: email,
      ancien: ancienMotDePasse,
      nouveau: nouveauMotDePasse,
    );

    if (!ok) {
      return AuthResult(succes: false, messageErreur: 'Ancien mot de passe incorrect.');
    }

    return AuthResult(succes: true);
  }

  @override
  Future<AuthResult> reinitialiserMotDePasse({
    required String email,
    required String nouveauMotDePasse,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (nouveauMotDePasse.trim().length < 6) {
      return AuthResult(succes: false, messageErreur: '6 caractères minimum requis.');
    }

    final ok = await _store.reinitialiserMotDePasse(
      email: email,
      nouveau: nouveauMotDePasse,
    );

    if (!ok) {
      // Message volontairement générique (on ne confirme pas si l'email existe).
      return AuthResult(
        succes: false,
        messageErreur: "Si ce compte existe, le mot de passe n'a pas pu être réinitialisé.",
      );
    }

    // Déblocage anti-bruteforce associé, par cohérence.
    _tentativesEchoueesParEmail.remove(email.trim().toLowerCase());

    return AuthResult(succes: true);
  }
}