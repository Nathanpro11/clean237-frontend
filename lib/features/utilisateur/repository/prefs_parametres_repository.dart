import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clean237_frontend/features/utilisateur/repository/parametres_repository.dart';

/// Préférences persistées localement (SharedPreferences), sans backend.
class SharedPrefsParametresRepository implements ParametresRepository {
  static const _kPush = 'param_push';
  static const _kEmail = 'param_email';
  static const _kLoc = 'param_localisation';

  @override
  Future<PreferencesModel> chargerPreferences() async {
    final p = await SharedPreferences.getInstance();
    return PreferencesModel(
      notificationsPush: p.getBool(_kPush) ?? true,
      notificationsEmail: p.getBool(_kEmail) ?? false,
      localisationActive: p.getBool(_kLoc) ?? true,
    );
  }

  @override
  Future<void> enregistrerPreferences(PreferencesModel prefs) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kPush, prefs.notificationsPush);
    await p.setBool(_kEmail, prefs.notificationsEmail);
    await p.setBool(_kLoc, prefs.localisationActive);
  }

  @override
  Future<void> viderCache() async {
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
  }
}