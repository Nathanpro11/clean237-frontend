import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class ItineraireException implements Exception {
  final String message;
  ItineraireException(this.message);

  @override
  String toString() => message;
}

class Itineraire {
  final List<LatLng> points;
  final double distanceM;
  final double dureeS;

  Itineraire({required this.points, required this.distanceM, required this.dureeS});
}

/// Calcule un itinéraire sur les routes réelles avec le service gratuit d'OpenStreetMap.
class ItineraireService {
  static Future<Itineraire> calculer(
    LatLng depart,
    LatLng arrivee, {
    bool aPied = true,
  }) async {
    final profil = aPied ? 'routed-foot/route/v1/foot' : 'routed-car/route/v1/driving';
    final coordonnees =
        '${depart.longitude},${depart.latitude};${arrivee.longitude},${arrivee.latitude}';
    final uri = Uri.parse(
      'https://routing.openstreetmap.de/$profil/$coordonnees?overview=full&geometries=geojson',
    );
    try {
      final reponse = await http
          .get(uri, headers: {'User-Agent': 'Clean237/1.0'})
          .timeout(const Duration(seconds: 20));
      if (reponse.statusCode != 200) {
        throw ItineraireException(
          "Service d'itinéraires indisponible (${reponse.statusCode}).",
        );
      }
      final donnees = jsonDecode(utf8.decode(reponse.bodyBytes));
      final routes = donnees['routes'];
      if (donnees['code'] != 'Ok' || routes is! List || routes.isEmpty) {
        throw ItineraireException('Aucun itinéraire trouvé.');
      }
      final route = routes.first as Map<String, dynamic>;
      final coordonneesRoute = route['geometry']['coordinates'] as List;
      final points = coordonneesRoute
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();
      return Itineraire(
        points: points,
        distanceM: (route['distance'] as num).toDouble(),
        dureeS: (route['duration'] as num).toDouble(),
      );
    } on ItineraireException {
      rethrow;
    } on TimeoutException {
      throw ItineraireException("Le service d'itinéraires met trop de temps à répondre.");
    } catch (_) {
      throw ItineraireException("Impossible de calculer l'itinéraire. Vérifie ta connexion.");
    }
  }
}
