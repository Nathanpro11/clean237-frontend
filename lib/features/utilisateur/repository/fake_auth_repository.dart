import 'package:clean237_frontend/features/utilisateur/models/utilisateur_model.dart';
import 'package:clean237_frontend/features/utilisateur/repository/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  static const _emailTest = 'test@clean237.cm';
  static const _motDePasseTest = '123456';

  int _tentativesEchouees = 0;

  // 🧪 État interne simulé de l'utilisateur connecté (pour permettre
  // à modifierProfil / changerMotDePasse de "persister" pendant la session)
  UtilisateurModel? _utilisateurActuel;
  String _motDePasseActuel = _motDePasseTest;

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

    if (email.trim().toLowerCase() == _emailTest &&
        motDepasse.trim() == _motDePasseActuel) {
      _tentativesEchouees = 0;
      _utilisateurActuel = UtilisateurModel(
        id: '1',
        nom: 'Jean Testeur',
        email: email,
        telephone: '+237600000000',
        roleNom: 'citoyen',
        permissions: const ['lire_signalement', 'creer_signalement'],
        estActif: true,
      );
      return AuthResult(
        succes: true,
        token: 'fake-jwt-token-123',
        utilisateur: _utilisateurActuel,
      );
    }

    _tentativesEchouees++;
    return AuthResult(
      succes: false,
      messageErreur:
          'Identifiants invalides (utilise $_emailTest / $_motDePasseActuel).',
    );
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

    if (email.trim().toLowerCase() == _emailTest) {
      return AuthResult(
        succes: false,
        messageErreur: 'Cet email est déjà utilisé (simulation).',
      );
    }

    return AuthResult(succes: true);
  }

  @override
  Future<AuthResult> modifierProfil({
    required String nom,
    required String telephone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (_utilisateurActuel == null) {
      return AuthResult(succes: false, messageErreur: 'Aucun utilisateur connecté.');
    }

    if (nom.trim().isEmpty) {
      return AuthResult(succes: false, messageErreur: 'Le nom ne peut pas être vide.');
    }

    _utilisateurActuel = UtilisateurModel(
      id: _utilisateurActuel!.id,
      nom: nom.trim(),
      email: _utilisateurActuel!.email,
      telephone: telephone.trim(),
      matricule: _utilisateurActuel!.matricule,
      zoneAffectee: _utilisateurActuel!.zoneAffectee,
      roleNom: _utilisateurActuel!.roleNom,
      permissions: _utilisateurActuel!.permissions,
      estActif: _utilisateurActuel!.estActif,
    );

    return AuthResult(succes: true, utilisateur: _utilisateurActuel);
  }

  @override
  Future<AuthResult> changerMotDePasse({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (ancienMotDePasse.trim() != _motDePasseActuel) {
      return AuthResult(succes: false, messageErreur: 'Ancien mot de passe incorrect.');
    }

    if (nouveauMotDePasse.trim().length < 6) {
      return AuthResult(succes: false, messageErreur: '6 caractères minimum requis.');
    }

    _motDePasseActuel = nouveauMotDePasse.trim();
    return AuthResult(succes: true);
  }
}