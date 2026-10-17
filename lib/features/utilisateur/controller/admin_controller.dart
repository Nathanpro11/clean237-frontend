import 'package:flutter/material.dart';
import 'package:clean237_frontend/features/utilisateur/models/utilisateur_model.dart';
import 'package:clean237_frontend/features/utilisateur/repository/admin_repository.dart';
import 'package:clean237_frontend/utils/api_client.dart';

class AdminController extends ChangeNotifier {
  final AdminRepository _repository;

  AdminController(this._repository);

  StatsAdmin? _stats;
  List<UtilisateurModel> _utilisateurs = [];
  bool _enChargement = false;
  String? _messageErreur;

  StatsAdmin? get stats => _stats;
  List<UtilisateurModel> get utilisateurs => _utilisateurs;
  bool get enChargement => _enChargement;
  String? get messageErreur => _messageErreur;

  /// Message du serveur si disponible, sinon [parDefaut].
  String _message(Object e, String parDefaut) =>
      e is ApiException ? e.message : parDefaut;

  Future<void> chargerTableauDeBord() async {
    _enChargement = true;
    _messageErreur = null;
    notifyListeners();

    try {
      _stats = await _repository.chargerStats();
    } catch (e) {
      _messageErreur = _message(e, 'Impossible de charger les statistiques.');
    }

    _enChargement = false;
    notifyListeners();
  }

  Future<void> chargerUtilisateurs() async {
    _enChargement = true;
    _messageErreur = null;
    notifyListeners();

    try {
      _utilisateurs = await _repository.chargerUtilisateurs();
    } catch (e) {
      _messageErreur = _message(e, 'Impossible de charger les comptes.');
    }

    _enChargement = false;
    notifyListeners();
  }

  Future<bool> mettreAJourUtilisateur({
    required String id,
    bool? estActif,
    String? roleNom,
    List<String>? permissions,
  }) async {
    _messageErreur = null;
    try {
      final modifie = await _repository.mettreAJourUtilisateur(
        id: id,
        estActif: estActif,
        roleNom: roleNom,
        permissions: permissions,
      );
      _utilisateurs = _utilisateurs.map((u) => u.id == id ? modifie : u).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _messageErreur = _message(e, 'La mise à jour a échoué.');
      notifyListeners();
      return false;
    }
  }

  /// Création directe d'un compte depuis le panneau admin.
  Future<bool> creerUtilisateur({
    required String nom,
    required String email,
    required String telephone,
    required String motDepasse,
    required String roleNom,
    String? matricule,
    String? zoneAffectee,
  }) async {
    _messageErreur = null;
    try {
      final nouveau = await _repository.creerUtilisateur(
        nom: nom,
        email: email,
        telephone: telephone,
        motDepasse: motDepasse,
        roleNom: roleNom,
        matricule: matricule,
        zoneAffectee: zoneAffectee,
      );
      _utilisateurs = [..._utilisateurs, nouveau];
      notifyListeners();
      return true;
    } catch (e) {
      _messageErreur = _message(e, e.toString().replaceFirst('Exception: ', ''));
      notifyListeners();
      return false;
    }
  }

  /// Point d'entrée pour le dialogue de création de compte admin : reçoit
  /// les valeurs BRUTES du formulaire (FormBuilder) et le rôle sélectionné,
  /// fait tout le nettoyage/mapping ici (téléphone, trim, matricule/zone si agent).
  Future<bool> soumettreCreationCompte(Map<String, dynamic> valeursFormulaire, String role) {
    final telephoneNettoye =
        (valeursFormulaire['telephone'] as String).replaceAll(RegExp(r'[\s-]'), '');

    return creerUtilisateur(
      nom: (valeursFormulaire['nom'] as String).trim(),
      email: (valeursFormulaire['email'] as String).trim().toLowerCase(),
      telephone: telephoneNettoye,
      motDepasse: valeursFormulaire['motDepasse'] as String,
      roleNom: role,
      matricule: role == 'agent' ? (valeursFormulaire['matricule'] as String?)?.trim() : null,
      zoneAffectee: role == 'agent' ? (valeursFormulaire['zone'] as String?)?.trim() : null,
    );
  }

  Future<String> dernierIpAudite(String utilisateurId) {
    return _repository.dernierIpAudite(utilisateurId);
  }
}