import 'package:flutter/material.dart';
import 'package:clean237_frontend/features/utilisateur/models/utilisateur_model.dart';
import 'package:clean237_frontend/features/utilisateur/repository/admin_repository.dart';

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

  Future<void> chargerTableauDeBord() async {
    _enChargement = true;
    _messageErreur = null;
    notifyListeners();

    try {
      _stats = await _repository.chargerStats();
    } catch (_) {
      _messageErreur = 'Impossible de charger les statistiques.';
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
    } catch (_) {
      _messageErreur = 'Impossible de charger les comptes.';
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
    } catch (_) {
      _messageErreur = 'La mise à jour a échoué.';
      notifyListeners();
      return false;
    }
  }

  Future<String> dernierIpAudite(String utilisateurId) {
    return _repository.dernierIpAudite(utilisateurId);
  }
}