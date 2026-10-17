import 'package:flutter/material.dart';
import 'package:clean237_frontend/features/utilisateur/models/log_model.dart';
import 'package:clean237_frontend/utils/api_client.dart';

/// ViewModel de l'historique d'activité (audit) et du support de l'utilisateur connecté.
class ProfilController extends ChangeNotifier {
  List<LogModel> _historiqueLogs = [];
  bool _enChargement = false;
  String? _messageErreur;

  List<LogModel> get historiqueLogs => _historiqueLogs;
  bool get enChargement => _enChargement;
  String? get messageErreur => _messageErreur;

  Future<void> chargerHistorique() async {
    _enChargement = true;
    _messageErreur = null;
    notifyListeners();

    try {
      final data = await ApiClient.get('/utilisateurs/historique/${ApiClient.userId}');
      _historiqueLogs = (data['historique'] as List? ?? [])
          .map((j) => LogModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _messageErreur = e is ApiException ? e.message : "Impossible de charger l'historique.";
    }

    _enChargement = false;
    notifyListeners();
  }

  /// Envoie un message au support (enregistré en base). Retourne null si OK,
  /// sinon le message d'erreur à afficher.
  Future<String?> envoyerMessageSupport(String message) async {
    try {
      await ApiClient.post('/utilisateurs/support', {'message': message.trim()});
      return null;
    } catch (e) {
      return e is ApiException ? e.message : "Impossible d'envoyer le message.";
    }
  }
}