import 'package:clean237_frontend/utils/api_client.dart';
import '../models/signalement_model.dart';
import '../models/notification_model.dart';

/// Appelle /api/v1/signalements et /api/v1/notifications.
/// L'identité (citoyen ou agent) vient du jeton : aucun id à envoyer.
class SignalementService {
  List<Signalement> _liste(dynamic d) =>
      (d['data'] as List).map((e) => Signalement.fromJson(e as Map<String, dynamic>)).toList();

  // ---------- Citoyen ----------
  Future<Signalement> creerSignalement(Signalement s) async {
    final d = await ApiClient.post('/v1/signalements', s.toJson());
    return Signalement.fromJson(d as Map<String, dynamic>);
  }

  Future<List<Signalement>> mesSignalements() async =>
      _liste(await ApiClient.get('/v1/signalements/mes-signalements', query: {'limit': '50'}));

  Future<Signalement> getSignalementParId(String id) async =>
      Signalement.fromJson(await ApiClient.get('/v1/signalements/$id') as Map<String, dynamic>);

  Future<void> modifierSignalement(
    String id, {
    String? description,
    String? quartier,
    String? precision,
  }) async {
    final body = <String, dynamic>{};
    if (description != null) body['description'] = description;
    if (quartier != null) body['quartier'] = quartier;
    if (precision != null) body['precision'] = precision;
    await ApiClient.put('/v1/signalements/$id', body);
  }

  Future<void> annulerSignalement(String id) => ApiClient.patch('/v1/signalements/$id/annuler');

  Future<void> archiverSignalement(String id) => ApiClient.patch('/v1/signalements/$id/archiver');

  // ---------- Agent ----------
  Future<List<Signalement>> aTraiter() async =>
      _liste(await ApiClient.get('/v1/signalements/a-traiter', query: {'limit': '50'}));

  Future<List<Signalement>> historiqueAgent() async =>
      _liste(await ApiClient.get('/v1/signalements/historique-agent', query: {'limit': '50'}));

  Future<void> changerStatut(String id, String statut, {String? motifRejet}) {
    final body = <String, dynamic>{'statut': statut};
    if (motifRejet != null) body['motifRejet'] = motifRejet;
    return ApiClient.patch('/v1/signalements/$id/statut', body);
  }

  // ---------- Notifications (celles de l'utilisateur connecté) ----------
  Future<List<AppNotification>> listerNotifications() async {
    final d = await ApiClient.get('/v1/notifications');
    return (d['data'] as List).map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> marquerLue(String id) => ApiClient.patch('/v1/notifications/$id/lu');
}
