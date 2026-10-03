import 'package:clean237_frontend/features/utilisateur/models/utilisateur_model.dart';

/// Source UNIQUE des comptes utilisateurs simulés (mode sans backend).
/// Partagée par FakeAuthRepository (connexion/inscription/profil) et
/// FakeAdminRepository (gestion des comptes) : un compte créé, désactivé
/// ou modifié d'un côté est immédiatement visible et effectif de l'autre.
class UtilisateursStore {
  UtilisateursStore() {
    _initialiserComptesDeDemo();
  }

  final Map<String, UtilisateurModel> _comptes = {};
  final Map<String, String> _motsDePasse = {};
  int _prochainId = 1;

  String _idSuivant() => '${_prochainId++}';

  void _ajouter(UtilisateurModel utilisateur, {required String motDePasse}) {
    _comptes[utilisateur.email] = utilisateur;
    _motsDePasse[utilisateur.email] = motDePasse;
  }

  void _initialiserComptesDeDemo() {
    _ajouter(
      UtilisateurModel(
        id: _idSuivant(),
        nom: 'Jean Testeur',
        email: 'test@clean237.cm',
        telephone: '+237600000000',
        roleNom: 'citoyen',
        permissions: const ['lire_signalement', 'creer_signalement'],
        estActif: true,
      ),
      motDePasse: '123456',
    );

    _ajouter(
      UtilisateurModel(
        id: _idSuivant(),
        nom: 'Néhémi Mbainadji',
        email: 'agent@clean237.cm',
        telephone: '+237600000001',
        matricule: 'AGT-237-001',
        zoneAffectee: 'Yaoundé VI',
        roleNom: 'agent',
        permissions: const ['lire_mission', 'maj_collecte'],
        estActif: true,
      ),
      motDePasse: '123456',
    );

    _ajouter(
      UtilisateurModel(
        id: _idSuivant(),
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
      motDePasse: '123456',
    );

    // Comptes de démonstration supplémentaires, visibles dans le tableau admin.
    _ajouter(
      UtilisateurModel(
        id: _idSuivant(),
        nom: 'Weezy Kolomso',
        email: 'weezy.kolomso@clean237.cm',
        telephone: '+237677000010',
        roleNom: 'citoyen',
        permissions: const ['creer_utilisateur'],
        estActif: true,
      ),
      motDePasse: '123456',
    );

    _ajouter(
      UtilisateurModel(
        id: _idSuivant(),
        nom: 'Paul Essomba',
        email: 'paul.essomba@clean237.cm',
        telephone: '+237677000011',
        matricule: 'AGT-237-014',
        zoneAffectee: 'Yaoundé VI',
        roleNom: 'agent',
        permissions: const ['modifier_utilisateur'],
        estActif: false,
      ),
      motDePasse: '123456',
    );
  }

  UtilisateurModel? trouverParEmail(String email) => _comptes[email.trim().toLowerCase()];

  String? motDePassePour(String email) => _motsDePasse[email.trim().toLowerCase()];

  bool emailExiste(String email) => _comptes.containsKey(email.trim().toLowerCase());

  List<UtilisateurModel> listerTous() => List.unmodifiable(_comptes.values);

  UtilisateurModel creerCompte({
    required String nom,
    required String email,
    required String telephone,
    required String motDepasse,
    required String roleNom,
    String? matricule,
    String? zoneAffectee,
  }) {
    final emailNormalise = email.trim().toLowerCase();

    final permissionsParDefaut = roleNom == 'agent'
        ? const ['lire_mission', 'maj_collecte']
        : const ['lire_signalement', 'creer_signalement'];

    final nouveau = UtilisateurModel(
      id: _idSuivant(),
      nom: nom.trim(),
      email: emailNormalise,
      telephone: telephone.trim(),
      matricule: roleNom == 'agent' ? matricule : null,
      zoneAffectee: roleNom == 'agent' ? zoneAffectee : null,
      roleNom: roleNom,
      permissions: permissionsParDefaut,
      estActif: true,
    );

    _ajouter(nouveau, motDePasse: motDepasse.trim());
    return nouveau;
  }

  UtilisateurModel mettreAJourProfil({
    required String email,
    required String nom,
    required String telephone,
  }) {
    final emailNormalise = email.trim().toLowerCase();
    final actuel = _comptes[emailNormalise]!;

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

    _comptes[emailNormalise] = modifie;
    return modifie;
  }

  bool changerMotDePasse({
    required String email,
    required String ancien,
    required String nouveau,
  }) {
    final emailNormalise = email.trim().toLowerCase();
    if (_motsDePasse[emailNormalise] != ancien.trim()) return false;
    _motsDePasse[emailNormalise] = nouveau.trim();
    return true;
  }

  /// Flux "mot de passe oublié" : réinitialise directement le mot de passe
  /// du compte correspondant à [email], sans exiger l'ancien mot de passe.
  /// Renvoie false si l'email ne correspond à aucun compte.
  bool reinitialiserMotDePasse({
    required String email,
    required String nouveau,
  }) {
    final emailNormalise = email.trim().toLowerCase();
    if (!_comptes.containsKey(emailNormalise)) return false;
    _motsDePasse[emailNormalise] = nouveau.trim();
    return true;
  }

  UtilisateurModel mettreAJourDroits({
    required String id,
    bool? estActif,
    String? roleNom,
    List<String>? permissions,
  }) {
    final entree = _comptes.entries.firstWhere((e) => e.value.id == id);
    final actuel = entree.value;

    final modifie = UtilisateurModel(
      id: actuel.id,
      nom: actuel.nom,
      email: actuel.email,
      telephone: actuel.telephone,
      matricule: actuel.matricule,
      zoneAffectee: actuel.zoneAffectee,
      roleNom: roleNom ?? actuel.roleNom,
      permissions: permissions ?? actuel.permissions,
      estActif: estActif ?? actuel.estActif,
    );

    _comptes[entree.key] = modifie;
    return modifie;
  }
}