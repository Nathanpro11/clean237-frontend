import 'package:clean237_frontend/features/utilisateur/models/utilisateur_model.dart';
import 'package:clean237_frontend/features/utilisateur/repository/auth_repository.dart';
import 'package:clean237_frontend/utils/jwt_helper.dart';

/// Implémentation FACTICE d'AuthRepository (sans backend).
/// Comptes de démonstration préchargés (mot de passe : 123456) :
///   test@clean237.cm   -> citoyen
///   agent@clean237.cm  -> agent de terrain
///   admin@clean237.cm  -> Super-Admin
/// Tout compte créé via inscrireUnUtilisateur() est aussi enregistré ici,
/// avec son propre mot de passe, et devient utilisable pour se connecter.
class FakeAuthRepository implements AuthRepository {
  int _tentativesEchouees = 0;
  int _prochainId = 4;

  UtilisateurModel? _utilisateurActuel;

  final Map<String, UtilisateurModel> _comptes = {
    'test@clean237.cm': UtilisateurModel(
      id: '1',
      nom: 'Jean Testeur',
      email: 'test@clean237.cm',
      telephone: '+237600000000',
      roleNom: 'citoyen',
      permissions: const ['lire_signalement', 'creer_signalement'],
      estActif: true,
    ),
    'agent@clean237.cm': UtilisateurModel(
      id: '2',
      nom: 'Néhémi Mbainadji',
      email: 'agent@clean237.cm',
      telephone: '+237600000001',
      matricule: 'AGT-237-001',
      zoneAffectee: 'Yaoundé VI',
      roleNom: 'agent',
      permissions: const ['lire_mission', 'maj_collecte'],
      estActif: true,
    ),
    'admin@clean237.cm': UtilisateurModel(
      id: '3',
      nom: 'Admin Yaoundé VI',
      email: 'admin@clean237.cm',
      telephone: '+237600000002',
      roleNom: 'admin',
      permissions: const [
        'creer_utilisateur',
        'modifier_utilisateur',
        'supprimer_utilisateur',
        'creer_role',
        'consulter_logs',
      ],
      estActif: true,
    ),
  };

  // Mot de passe propre à chaque compte (au lieu d'un seul mot de passe global).
  final Map<String, String> _motsDePasse = {
    'test@clean237.cm': '123456',
    'agent@clean237.cm': '123456',
    'admin@clean237.cm': '123456',
  };

  @override
  Future<AuthResult> login(String email, String motDepasse) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final emailNormalise = email.trim().toLowerCase();

    if (_tentativesEchouees >= 3) {
      return AuthResult(
        succes: false,
        estBloqueAntiBruteforce: true,
        messageErreur:
            'Trop de tentatives échouées. Compte temporairement bloqué (simulation).',
      );
    }

    final compte = _comptes[emailNormalise];
    final motDePasseAttendu = _motsDePasse[emailNormalise];

    if (compte != null && motDePasseAttendu != null && motDepasse.trim() == motDePasseAttendu) {
      if (!compte.estActif) {
        return AuthResult(succes: false, messageErreur: 'Ce compte est désactivé.');
      }

      _tentativesEchouees = 0;
      _utilisateurActuel = compte;

      final token = JwtHelper.creerTokenFactice({
        'id': compte.id,
        'email': compte.email,
        'role': {'nom': compte.roleNom, 'permissionsIds': compte.permissions},
        'exp': DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
      });

      return AuthResult(succes: true, token: token, utilisateur: compte);
    }

    _tentativesEchouees++;
    return AuthResult(
      succes: false,
      messageErreur: 'Identifiants invalides.',
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

    final emailNormalise = email.trim().toLowerCase();

    if (_comptes.containsKey(emailNormalise)) {
      return AuthResult(
        succes: false,
        messageErreur: 'Cet email est déjà utilisé.',
      );
    }

    final permissionsParDefaut = profil == 'agent'
        ? const ['lire_mission', 'maj_collecte']
        : const ['lire_signalement', 'creer_signalement'];

    final nouveauCompte = UtilisateurModel(
      id: '${_prochainId++}',
      nom: nom.trim(),
      email: emailNormalise,
      telephone: telephone.trim(),
      matricule: profil == 'agent' ? matricule : null,
      zoneAffectee: profil == 'agent' ? zoneAffectee : null,
      roleNom: profil,
      permissions: permissionsParDefaut,
      estActif: true,
    );

    // Le compte est réellement enregistré : on peut ensuite s'y connecter.
    _comptes[emailNormalise] = nouveauCompte;
    _motsDePasse[emailNormalise] = motDepasse.trim();

    return AuthResult(succes: true, utilisateur: nouveauCompte);
  }

  @override
  Future<AuthResult> modifierProfil({
    required String nom,
    required String telephone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final actuel = _utilisateurActuel;
    if (actuel == null) {
      return AuthResult(succes: false, messageErreur: 'Aucun utilisateur connecté.');
    }

    if (nom.trim().isEmpty) {
      return AuthResult(succes: false, messageErreur: 'Le nom ne peut pas être vide.');
    }

    final modifie = UtilisateurModel(
      id: actuel.id,
      nom: nom.trim(),
      email: actuel.email,
      telephone: telephone.trim(),
      matricule: actuel.matricule,
      zoneAffectee: actuel.zoneAffectee,
      roleNom: actuel.roleNom,
      permissions: actuel.permissions,
      estActif: actuel.estActif,
    );

    _utilisateurActuel = modifie;
    _comptes[modifie.email] = modifie;
    return AuthResult(succes: true, utilisateur: modifie);
  }

  @override
  Future<AuthResult> changerMotDePasse({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final actuel = _utilisateurActuel;
    if (actuel == null) {
      return AuthResult(succes: false, messageErreur: 'Aucun utilisateur connecté.');
    }

    if (_motsDePasse[actuel.email] != ancienMotDePasse.trim()) {
      return AuthResult(succes: false, messageErreur: 'Ancien mot de passe incorrect.');
    }

    if (nouveauMotDePasse.trim().length < 6) {
      return AuthResult(succes: false, messageErreur: '6 caractères minimum requis.');
    }

    _motsDePasse[actuel.email] = nouveauMotDePasse.trim();
    return AuthResult(succes: true);
  }
}