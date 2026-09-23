import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ✅ REMPLACEZ LES ANCIENS IMPORTS DE 'core' PAR CEUX-CI DANS VOS CONTROLLERS :
import 'package:clean237_frontend/utils/api_client.dart';
import 'package:clean237_frontend/features/utilisateur/models/utilisateur_model.dart';
import 'package:clean237_frontend/features/utilisateur/models/log_model.dart';


class AuthController extends ChangeNotifier {
  final String _endpointUrl = '${ApiClient.baseUrl}/utilisateurs';
  
  UtilisateurModel? _utilisateurConnecte;
  String? _tokenJwt;
  bool _estEnCoursDeChargement = false;
  String? _messageErreur;
  bool _estBloqueAntiBruteforce = false;

  // Getters pour donner l'accès en lecture seule à tes Views (Écrans)
  UtilisateurModel? get utilisateur => _utilisateurConnecte;
  String? get token => _tokenJwt;
  bool get estEnCoursDeChargement => _estEnCoursDeChargement;
  String? get messageErreur => _messageErreur;
  bool get estBloqueAntiBruteforce => _estBloqueAntiBruteforce;

  void _setChargement(bool valeur) {
    _estEnCoursDeChargement = valeur;
    notifyListeners(); // 🎯 MVVM : Notifie les widgets Flutter de se redessiner
  }

  // 🔐 ACTION NET: Connexion liée à ton routeur express POST /login
  Future<bool> login(String email, String motDepasse) async {
    _setChargement(true);
    _messageErreur = null;
    _estBloqueAntiBruteforce = false;

    try {
      final response = await http.post(
        Uri.parse('$_endpointUrl/login'),
        headers: ApiClient.getHeaders(),
        body: jsonEncode({
          'email': email,
          'motDepasse': motDepasse,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _tokenJwt = responseData['token'] as String?;
        if (responseData['data'] != null) {
          _utilisateurConnecte = UtilisateurModel.fromJson(responseData['data']);
        }
        _setChargement(false);
        return true;
      } 
      // 🎯 SÉCURITÉ : Interception de l'exception Anti-Bruteforce de ton Backend
      else if (response.statusCode == 429) {
        _estBloqueAntiBruteforce = true;
        _messageErreur = responseData['message'] as String? ?? 'Compte temporairement bloqué.';
        _setChargement(false);
        return false;
      } 
      else {
        _messageErreur = responseData['message'] as String? ?? 'Identifiants invalides.';
        _setChargement(false);
        return false;
      }
    } catch (error) {
      _messageErreur = 'Erreur de connexion. Vérifie que le Backend tourne sur le port 3000.';
      _setChargement(false);
      return false;
    }
  }

  // 📝 ACTION NET: Inscription liée à ton routeur express POST /create
  Future<bool> inscrireUnUtilisateur({
    required String nom,
    required String email,
    required String telephone,
    required String motDepasse,
    required String profil,
    String? matricule,
    String? zoneAffectee,
  }) async {
    _setChargement(true);
    _messageErreur = null;

    try {
      final response = await http.post(
        Uri.parse('$_endpointUrl/create'),
        headers: ApiClient.getHeaders(),
        body: jsonEncode({
          'nom': nom,
          'email': email,
          'telephone': telephone,
          'motDepasse': motDepasse,
          'profil': profil,
          if (matricule != null && matricule.isNotEmpty) 'matricule': matricule,
          if (zoneAffectee != null && zoneAffectee.isNotEmpty) 'zoneAffectee': zoneAffectee,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _setChargement(false);
        return true;
      } else {
        _messageErreur = responseData['message'] as String? ?? "Impossible de créer le compte.";
        _setChargement(false);
        return false;
      }
    } catch (error) {
      _messageErreur = 'Erreur réseau lors de la création du profil.';
      _setChargement(false);
      return false;
    }
  }

  void logout() {
    _utilisateurConnecte = null;
    _tokenJwt = null;
    _messageErreur = null;
    _estBloqueAntiBruteforce = false;
    notifyListeners();
  }
}
