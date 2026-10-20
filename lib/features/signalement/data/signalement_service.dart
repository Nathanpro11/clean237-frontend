import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/signalement_model.dart';
import '../models/notification_model.dart';

class SignalementService {
  final String baseUrl = 'http://10.0.2.2:3000/api'; // emulateur Android

  Map<String, dynamic> _decode(http.Response r) => jsonDecode(r.body);
  List<dynamic> _decodeList(http.Response r) =>
      jsonDecode(r.body) as List<dynamic>;

  // ---------- Citoyen ----------
  Future<Signalement> creerSignalement(Signalement s) async {
    final res = await http.post(
      Uri.parse('$baseUrl/signalements'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(s.toJson()),
    );
    if (res.statusCode == 201) return Signalement.fromJson(_decode(res));
    throw Exception(_decode(res)['message'] ?? 'Erreur de creation');
  }

  Future<List<Signalement>> mesSignalements(String citoyenId) async {
    final res = await http.get(
      Uri.parse(
        '$baseUrl/citoyens/$citoyenId/mes-signalements?page=1&limit=20',
      ),
    );
    if (res.statusCode == 200)
      return _decodeList(res).map((e) => Signalement.fromJson(e)).toList();
    throw Exception('Erreur de chargement');
  }

  Future<Signalement> getSignalementParId(String id) async {
    final res = await http.get(Uri.parse('$baseUrl/signalements/$id'));
    if (res.statusCode == 200) return Signalement.fromJson(_decode(res));
    throw Exception('Signalement introuvable');
  }

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
    final res = await http.put(
      Uri.parse('$baseUrl/signalements/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode != 200)
      throw Exception(_decode(res)['message'] ?? 'Erreur de modification');
  }

  Future<void> annulerSignalement(String id) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/signalements/$id/annuler'),
    );
    if (res.statusCode != 200)
      throw Exception(_decode(res)['message'] ?? 'Erreur d\'annulation');
  }

  Future<void> archiverSignalement(String id) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/signalements/$id/archiver'),
    );
    if (res.statusCode != 200) throw Exception('Erreur d\'archivage');
  }

  // ---------- Agent ----------
  Future<List<Signalement>> aTraiter(String agentId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/agents/$agentId/a-traiter?page=1&limit=20'),
    );
    if (res.statusCode == 200)
      return _decodeList(res).map((e) => Signalement.fromJson(e)).toList();
    throw Exception('Erreur de chargement');
  }

  Future<List<Signalement>> historiqueAgent(String agentId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/agents/$agentId/historique?page=1&limit=20'),
    );
    if (res.statusCode == 200)
      return _decodeList(res).map((e) => Signalement.fromJson(e)).toList();
    throw Exception('Erreur de chargement');
  }

  Future<void> changerStatut(
    String id,
    String statut, {
    String? motifRejet,
  }) async {
    final body = <String, dynamic>{'statut': statut};
    if (motifRejet != null) body['motifRejet'] = motifRejet;
    final res = await http.patch(
      Uri.parse('$baseUrl/signalements/$id/statut'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode != 200)
      throw Exception(
        _decode(res)['message'] ?? 'Erreur de changement de statut',
      );
  }

  // ---------- Notifications ----------
  Future<List<AppNotification>> listerNotifications(String destinataire) async {
    final res = await http.get(
      Uri.parse('$baseUrl/notifications?destinataire=$destinataire'),
    );
    if (res.statusCode == 200)
      return _decodeList(res).map((e) => AppNotification.fromJson(e)).toList();
    throw Exception('Erreur de chargement');
  }

  Future<void> marquerLue(String id) async {
    await http.patch(Uri.parse('$baseUrl/notifications/$id/lu'));
  }

  Future<void> marquerToutesLues(String destinataire) async {
    await http.patch(
      Uri.parse(
        '$baseUrl/notifications/toutes-lues?destinataire=$destinataire',
      ),
    );
  }
}
