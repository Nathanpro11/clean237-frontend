import 'dart:async';
import 'package:geolocator/geolocator.dart';

class PositionService {
  /// Position réelle du téléphone. Lève une Exception avec un message clair en cas de souci.
  static Future<Position> positionActuelle() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Active la localisation (GPS) de ton téléphone.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Autorisation de localisation refusée.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        "Autorisation refusée définitivement : active-la dans les paramètres de l'application.",
      );
    }
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } on TimeoutException {
      throw Exception('Position introuvable. Sors à l\'extérieur et réessaie.');
    }
  }
}
