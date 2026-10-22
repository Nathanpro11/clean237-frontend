import 'package:clean237_frontend/utils/api_client.dart';
import '../models/bac_model.dart';

/// Appelle /api/v1/bacs et /api/v1/carte. L'identité vient du jeton.
class GeolocalisationService {
  List<dynamic> _brut(dynamic d) =>
      d is List ? d : (d is Map && d['data'] is List ? d['data'] as List : <dynamic>[]);

  List<Bac> _liste(dynamic d) =>
      _brut(d).map((e) => Bac.fromJson(e as Map<String, dynamic>)).toList();

  Future<List<Bac>> tousLesBacs() async => _liste(await ApiClient.get('/v1/bacs'));

  Future<List<ZoneSimple>> zones() async {
    final d = await ApiClient.get('/v1/carte');
    final brut = d is Map && d['zones'] is List ? d['zones'] as List : <dynamic>[];
    return brut.map((e) => ZoneSimple.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Réservés à l'admin (le serveur refuse les autres rôles)
  Future<void> creerBac(Map<String, dynamic> donnees) => ApiClient.post('/v1/bacs', donnees);

  Future<void> modifierBac(String id, Map<String, dynamic> donnees) =>
      ApiClient.put('/v1/bacs/$id', donnees);

  Future<void> supprimerBac(String id) => ApiClient.delete('/v1/bacs/$id');
}
