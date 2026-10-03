import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clean237_frontend/features/utilisateur/models/utilisateur_model.dart';

/// Source UNIQUE des comptes utilisateurs simulés (mode sans backend).
/// Partagée par FakeAuthRepository (connexion/inscription/profil) et
/// FakeAdminRepository (gestion des comptes) : un compte créé, désactivé
/// ou modifié d'un côté est immédiatement visible et effectif de l'autre.
///
/// Persisté localement (SharedPreferences) : les comptes créés pendant les
/// tests survivent à la fermeture de l'application.
class UtilisateursStore {
  static const _cle = 'clean237_comptes_v1';

  final Map<String, UtilisateurModel> _comptes = {};
  final Map<String, String> _motsDePasse = {};
  int _prochainId = 1;

  UtilisateursStore._();

  /// Construction asynchrone : charge les comptes sauvegardés s'il y en a,
  /// sinon initialise les comptes de démonstration.
  static Future<UtilisateursStore> creer() async {
    final store = UtilisateursStore._();
    final charge = await store._chargerDepuisDisque();
    if (!charge) {
      store._initialiserComptesDeDemo();
      await store._sauvegarder();
    }
    return store;
  }

  Future<bool> _chargerDepuisDisque() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final brut = prefs.getString(_cle);
      if (brut == null) return false;

      final liste = jsonDecode(brut) as List;
      if (liste.isEmpty) return false;

      int idMax = 0;
      for (final entree in liste) {
        final map = entree as Map<String, dynamic>;
        final utilisateur = UtilisateurModel.fromJson(map['utilisateur'] as Map<String, dynamic>);
        _comptes[utilisateur.email] = utilisateur;
        _motsDePasse[utilisateur.email] = map['motDePasse'] as String;
        final idNum = int.tryParse(utilisateur.id) ?? 0;
        if (idNum > idMax) idMax = idNum;
      }
      _prochainId = idMax + 1;
      return true;
    } catch (_) {
      // Lecture corrompue ou format inattendu : on repart sur les comptes de démo.
      return false;
    }
  }

  Future<void> _sauvegarder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final liste = _comptes.values
          .map((u) => {
                'utilisateur': u.toJson(),
                'motDePasse': _motsDePasse[u.email],
              })
          .toList();
      await prefs.setString(_cle, jsonEncode(liste));
    } catch (_) {
      // Persistance best-effort : une erreur d'écriture ne doit pas
      // interrompre le fonctionnement de l'application.
    }
  }

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

  Future<UtilisateurModel> creerCompte({
    required String nom,
    required String email,
    required String telephone,
    required String motDepasse,
    required String roleNom,
    String? matricule,
    String? zoneAffectee,
  }) async {
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
    await _sauvegarder();
    return nouveau;
  }

  Future<UtilisateurModel> mettreAJourProfil({
    required String email,
    required String nom,
    required String telephone,
  }) async {
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
    await _sauvegarder();
    return modifie;
  }

  Future<bool> changerMotDePasse({
    required String email,
    required String ancien,
    required String nouveau,
  }) async {
    final emailNormalise = email.trim().toLowerCase();
    if (_motsDePasse[emailNormalise] != ancien.trim()) return false;
    _motsDePasse[emailNormalise] = nouveau.trim();
    await _sauvegarder();
    return true;
  }

  /// Flux "mot de passe oublié" : réinitialise directement le mot de passe
  /// du compte correspondant à [email], sans exiger l'ancien mot de passe.
  Future<bool> reinitialiserMotDePasse({
    required String email,
    required String nouveau,
  }) async {
    final emailNormalise = email.trim().toLowerCase();
    if (!_comptes.containsKey(emailNormalise)) return false;
    _motsDePasse[emailNormalise] = nouveau.trim();
    await _sauvegarder();
    return true;
  }

  Future<UtilisateurModel> mettreAJourDroits({
    required String id,
    bool? estActif,
    String? roleNom,
    List<String>? permissions,
  }) async {
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
    await _sauvegarder();
    return modifie;
  }
}