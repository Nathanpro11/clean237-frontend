import 'dart:convert';

/// Outils JWT : fabrication d'un faux token (mode sans backend) et lecture
/// du payload pour résoudre le rôle, exactement comme avec le vrai token
/// renvoyé par le backend (port 3000).
class JwtHelper {
  static String creerTokenFactice(Map<String, dynamic> payload) {
    String encoder(Map<String, dynamic> donnees) =>
        base64Url.encode(utf8.encode(jsonEncode(donnees))).replaceAll('=', '');

    final entete = encoder({'alg': 'HS256', 'typ': 'JWT'});
    return '$entete.${encoder(payload)}.signature-factice';
  }

  static Map<String, dynamic>? decoderPayload(String? token) {
    if (token == null) return null;
    final parties = token.split('.');
    if (parties.length != 3) return null;

    try {
      final json = utf8.decode(base64Url.decode(base64Url.normalize(parties[1])));
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Lit le rôle dans le payload : { "role": { "nom": "admin", ... } }
  static String? extraireRole(String? token) {
    final role = decoderPayload(token)?['role'];
    if (role is Map) return role['nom'] as String?;
    if (role is String) return role;
    return null;
  }

  /// Vrai si le token est illisible ou expiré (claim "exp", en secondes).
  /// Un token sans "exp" est considéré valide.
  static bool estExpire(String? token) {
    final payload = decoderPayload(token);
    if (payload == null) return true;
    final exp = payload['exp'];
    if (exp is! num) return false;
    return DateTime.now().millisecondsSinceEpoch ~/ 1000 >= exp.toInt();
  }
}