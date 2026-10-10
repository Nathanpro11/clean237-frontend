import 'package:clean237_frontend/features/utilisateur/repository/parametres_repository.dart';

class FakeParametresRepository implements ParametresRepository {
  PreferencesModel _preferences = const PreferencesModel(
    notificationsPush: true,
    notificationsEmail: false,
    localisationActive: true,
  );

  @override
  Future<PreferencesModel> chargerPreferences() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _preferences;
  }

  @override
  Future<void> enregistrerPreferences(PreferencesModel preferences) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _preferences = preferences;
  }

  @override
  Future<void> viderCache() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Rien à vider en mode mock : simule juste le délai de l'opération.
  }
}