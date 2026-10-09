import 'package:flutter/material.dart';
import 'package:clean237_frontend/features/utilisateur/models/agent_stats_model.dart';
import 'package:clean237_frontend/features/utilisateur/repository/agent_repository.dart';

/// ViewModel du tableau de bord Agent de terrain (DashboardScreen).
class AgentController extends ChangeNotifier {
  final AgentRepository _repository;

  AgentController(this._repository);

  AgentStatsModel? _stats;
  bool _enChargement = false;
  String? _messageErreur;

  AgentStatsModel? get stats => _stats;
  bool get enChargement => _enChargement;
  String? get messageErreur => _messageErreur;

  Future<void> chargerStats() async {
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
}