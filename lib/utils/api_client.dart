import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Client HTTP unique : ajoute le JWT, décode le JSON, traduit les erreurs.
class ApiClient {
  // Émulateur Android : 10.0.2.2 = localhost du PC.
  // Téléphone physique : flutter run --dart-define=API_URL=http://<IP_DU_PC>:3000/api
  static const String baseUrl =
      String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:3000/api');
  static const Duration _delai = Duration(seconds: 15);

  static String? _token;
  static String? _userId;

  static String? get userId => _userId;
  static String? get token => _token;

  static void ouvrirSession({required String token, required String userId}) {
    _token = token;
    _userId = userId;
  }

  static void fermerSession() {
    _token = null;
    _userId = null;
  }

  static Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static Future<dynamic> get(String chemin, {Map<String, String>? query}) =>
      _appeler('GET', chemin, query: query);

  static Future<dynamic> post(String chemin, Map<String, dynamic> corps) =>
      _appeler('POST', chemin, corps: corps);

  static Future<dynamic> put(String chemin, Map<String, dynamic> corps) =>
      _appeler('PUT', chemin, corps: corps);

  static Future<dynamic> _appeler(
    String methode,
    String chemin, {
    Map<String, dynamic>? corps,
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('$baseUrl$chemin').replace(queryParameters: query);
    try {
      final json = corps == null ? null : jsonEncode(corps);
      final appel = switch (methode) {
        'POST' => http.post(uri, headers: _headers(), body: json),
        'PUT' => http.put(uri, headers: _headers(), body: json),
        _ => http.get(uri, headers: _headers()),
      };
      final reponse = await appel.timeout(_delai);
      final decode =
          reponse.bodyBytes.isEmpty ? null : jsonDecode(utf8.decode(reponse.bodyBytes));

      if (reponse.statusCode >= 400) {
        final message = decode is Map ? decode['message']?.toString() : null;
        throw ApiException(message ?? 'Erreur serveur (${reponse.statusCode})', reponse.statusCode);
      }
      return decode;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('Le serveur met trop de temps à répondre.');
    } on FormatException {
      throw ApiException('Réponse inattendue du serveur.');
    } catch (_) {
      throw ApiException("Serveur injoignable. Vérifiez la connexion et l'URL de l'API.");
    }
  }
}