import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:clean237_frontend/core/utils/api_client.dart';
import 'package:clean237_frontend/features/utilisateur/models/log_model.dart';
import 'package:clean237_frontend/features/utilisateur/models/utilisateur_model.dart';

class ProfilController extends ChangeNotifier {
  final String _endpointUrl = '${ApiClient.baseUrl}/utilisateurs';

  List<UtilisateurModel> _utilisateursList = [];
  List<LogModel> _historiqueLogs = [];
  Map<String, dynamic> _statistiquesDashboard = {};
  bool _estEnCoursDeChargement = false;
  String? _messageErreur;

  List<UtilisateurModel> get utilisateursList => _utilisateursList;
  List<LogModel> get historiqueLogs => _historiqueLogs;
  Map<String, dynamic> get statistiquesDashboard => _statistiquesDashboard;
  bool get estEnCoursDeChargement => _estEnCoursDeChargement;
  String? get messageErreur => _messageErreur;

  void _setChargement(bool valeur) {
    _estEnCoursDeChargement = valeur;
    notifyListeners();
  }

  // 📈 COUCHE ANALYTIQUE : Chargement du Dashboard Polymorphique selon le rôle
  Future<void> chargerDonneesDashboard(String idUser, String token, String roleId) async {
    _setChargement(true);
    _messageErreur = null;
    try {
      final response = await http.get(
        Uri.parse('$_endpointUrl/dashboard/stats/$idUser'),
        headers: ApiClient.getHeaders(token: token, roleId: roleId),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _statistiquesDashboard = data['statistiques'] as Map<String, dynamic>? ?? {};
      } else {
        _messageErreur = 'Erreur lors du calcul des indicateurs de salubrité.';
      }
    } catch (e) {
      _messageErreur = 'Erreur de communication avec le serveur analytique.';
    }
    _setChargement(false);
  }

  // 📜 TRAÇABILITÉ & AUDIT : Restitue la Timeline des logs et les adresses IP capturées
  Future<void> chargerTimelineLogs(String idUser, String token, String roleId) async {
    _setChargement(true);
    _messageErreur = null;
    try {
      final response = await http.get(
        Uri.parse('$_endpointUrl/historique/$idUser'),
        headers: ApiClient.getHeaders(token: token, roleId: roleId),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final listBrute = data['historique'] as List? ?? [];
        _historiqueLogs = listBrute.map((logJson) => LogModel.fromJson(logJson)).toList();
      } else {
        _messageErreur = 'Impossible de charger l\'historique d\'audit.';
      }
    } catch (e) {
      _messageErreur = 'Erreur réseau lors de la lecture des logs d\'immuabilité.';
    }
    _setChargement(false);
  }
}
