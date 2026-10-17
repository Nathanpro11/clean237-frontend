/// État des préférences utilisateur (notifications, confidentialité...).
class PreferencesModel {
  final bool notificationsPush;
  final bool notificationsEmail;
  final bool localisationActive;

  const PreferencesModel({
    required this.notificationsPush,
    required this.notificationsEmail,
    required this.localisationActive,
  });

  PreferencesModel copierAvec({
    bool? notificationsPush,
    bool? notificationsEmail,
    bool? localisationActive,
  }) {
    return PreferencesModel(
      notificationsPush: notificationsPush ?? this.notificationsPush,
      notificationsEmail: notificationsEmail ?? this.notificationsEmail,
      localisationActive: localisationActive ?? this.localisationActive,
    );
  }
}

/// Contrat des préférences utilisateur.
/// FakeParametresRepository maintenant (en mémoire), puis une implémentation
/// persistée (SharedPreferences ou backend) sans changer le ViewModel/la View.
abstract class ParametresRepository {
  Future<PreferencesModel> chargerPreferences();
  Future<void> enregistrerPreferences(PreferencesModel preferences);
  Future<void> viderCache();
}

