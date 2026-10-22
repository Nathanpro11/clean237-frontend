import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../data/geolocalisation_service.dart';
import '../data/position_service.dart';
import '../models/bac_model.dart';

class GeolocalisationController extends ChangeNotifier {
  final GeolocalisationService _service = GeolocalisationService();

  List<Bac> bacs = [];
  List<ZoneSimple> zones = [];
  LatLng? position;
  bool enChargement = false;
  String? messageErreur;
  String? messagePosition;

  Future<void> charger() async {
    enChargement = true;
    messageErreur = null;
    notifyListeners();
    try {
      bacs = await _service.tousLesBacs();
    } catch (e) {
      messageErreur = 'Impossible de charger les bacs';
    }
    enChargement = false;
    notifyListeners();
  }

  Future<void> chargerZones() async {
    try {
      zones = await _service.zones();
      notifyListeners();
    } catch (e) {
      messageErreur = 'Impossible de charger les zones';
      notifyListeners();
    }
  }

  Future<bool> creerBac(Map<String, dynamic> donnees) async {
    try {
      await _service.creerBac(donnees);
      messageErreur = null;
      await charger();
      return true;
    } catch (e) {
      messageErreur = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> modifierBac(String id, Map<String, dynamic> donnees) async {
    try {
      await _service.modifierBac(id, donnees);
      messageErreur = null;
      await charger();
      return true;
    } catch (e) {
      messageErreur = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> supprimerBac(String id) async {
    try {
      await _service.supprimerBac(id);
      bacs.removeWhere((b) => b.id == id);
      messageErreur = null;
      notifyListeners();
      return true;
    } catch (e) {
      messageErreur = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> localiser() async {
    messagePosition = null;
    try {
      final p = await PositionService.positionActuelle();
      position = LatLng(p.latitude, p.longitude);
    } catch (e) {
      messagePosition = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  /// Distance en mètres entre le téléphone et un bac (null si position inconnue).
  int? distanceVers(Bac b) {
    final p = position;
    if (p == null) return null;
    return const Distance()
        .as(LengthUnit.Meter, p, LatLng(b.latitude, b.longitude))
        .round();
  }

  Bac? get plusProche {
    if (position == null || bacs.isEmpty) return null;
    Bac? meilleur;
    var distanceMin = 1 << 30;
    for (final b in bacs) {
      final d = distanceVers(b)!;
      if (d < distanceMin) {
        distanceMin = d;
        meilleur = b;
      }
    }
    return meilleur;
  }
}
