import 'package:flutter/material.dart';
import 'package:clean237_frontend/features/utilisateur/models/citoyen_stats_model.dart';
import 'package:clean237_frontend/features/utilisateur/repository/citoyen_repository.dart';
import 'package:clean237_frontend/utils/api_client.dart';

/// ViewModel de l'accueil Citoyen (AccueilScreen).
class CitoyenController extends ChangeNotifier {
  final CitoyenRepository _repository;

  CitoyenController(this._repository);

  CitoyenStatsModel? _stats;
  bool _enChargement = false;
  String? _messageErreur;

  CitoyenStatsModel? get stats => _stats;
  bool get enChargement => _enChargement;
  String? get messageErreur => _messageErreur;

  Future<void> chargerStats() async {
    _enChargement = true;
    _messageErreur = null;
    notifyListeners();

    try {
      _stats = await _repository.chargerStats();
    } catch (e) {
      _messageErreur = e is ApiException ? e.message : 'Impossible de charger vos informations.';
    }

    _enChargement = false;
    notifyListeners();
  }
}