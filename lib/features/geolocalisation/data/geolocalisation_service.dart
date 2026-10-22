import 'package:clean237_frontend/utils/api_client.dart';
import '../models/bac_model.dart';

/// Appelle /api/v1/bacs. L'identité vient du jeton.
class GeolocalisationService {
  List<Bac> _liste(dynamic d) {
    final brut = d is List ? d : (d is Map && d['data'] is List ? d['data'] as List : <dynamic>[]);
    return brut.map((e) => Bac.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Bac>> tousLesBacs() async => _liste(await ApiClient.get('/v1/bacs'));
}
