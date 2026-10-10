import 'package:flutter/material.dart';
import 'package:clean237_frontend/features/utilisateur/repository/parametres_repository.dart';

/// ViewModel de l'écran Paramètres.
class ParametresController extends ChangeNotifier {
  final ParametresRepository _repository;

  ParametresController(this._repository);

  PreferencesModel? _preferences;
  bool _enChargement = false;
  String? _messageErreur;

  PreferencesModel? get preferences => _preferences;
  bool get enChargement => _enChargement;
  String? get messageErreur => _messageErreur;

  Future<void> chargerPreferences() async {
    _enChargement = true;
    _messageErreur = null;
    notifyListeners();

    try {
      _preferences = await _repository.chargerPreferences();
    } catch (_) {
      _messageErreur = 'Impossible de charger les préférences.';
    }

    _enChargement = false;
    notifyListeners();
  }

  Future<void> basculerNotificationsPush(bool valeur) async {
    if (_preferences == null) return;
    _preferences = _preferences!.copierAvec(notificationsPush: valeur);
    notifyListeners();
    await _repository.enregistrerPreferences(_preferences!);
  }

  Future<void> basculerNotificationsEmail(bool valeur) async {
    if (_preferences == null) return;
    _preferences = _preferences!.copierAvec(notificationsEmail: valeur);
    notifyListeners();
    await _repository.enregistrerPreferences(_preferences!);
  }

  Future<void> basculerLocalisation(bool valeur) async {
    if (_preferences == null) return;
    _preferences = _preferences!.copierAvec(localisationActive: valeur);
    notifyListeners();
    await _repository.enregistrerPreferences(_preferences!);
  }

  Future<void> viderCache() async {
    await _repository.viderCache();
  }
}