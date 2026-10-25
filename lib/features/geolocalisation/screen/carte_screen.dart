import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controller/geolocalisation_controller.dart';
import '../data/itineraire_service.dart';
import '../models/bac_model.dart';

class CarteScreen extends StatefulWidget {
  const CarteScreen({super.key});
  @override
  State<CarteScreen> createState() => _CarteScreenState();
}

class _CarteScreenState extends State<CarteScreen> {
  final _controller = GeolocalisationController();
  final _map = MapController();
  static const _centreParDefaut = LatLng(3.848, 11.502); // Yaoundé

  Bac? _cible;
  Itineraire? _itineraire;
  bool _aPied = true;
  bool _calcul = false;
  String? _erreurItineraire;
  int _requete = 0;

  @override
  void initState() {
    super.initState();
    _demarrer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _map.dispose();
    super.dispose();
  }

  /// Charge les bacs, prend la position du téléphone et trace la route vers le bac le plus proche.
  Future<void> _demarrer() async {
    await _controller.charger();
    await _controller.localiser();
    if (!mounted) return;
    final p = _controller.position;
    if (p == null) return;
    _deplacer(p, 15);
    final proche = _controller.plusProche;
    if (proche != null) await _tracer(proche);
  }

  void _deplacer(LatLng p, double zoom) {
    try {
      _map.move(p, zoom);
    } catch (_) {}
  }

  void _cadrer(Itineraire it) {
    try {
      _map.fitCamera(
        CameraFit.coordinates(
          coordinates: it.points,
          padding: const EdgeInsets.fromLTRB(40, 90, 40, 230),
        ),
      );
    } catch (_) {}
  }

  Future<void> _tracer(Bac b) async {
    final depart = _controller.position;
    setState(() {
      _cible = b;
      _itineraire = null;
      _erreurItineraire = null;
    });
    if (depart == null) {
      setState(() => _erreurItineraire =
          'Position inconnue : appuie sur le bouton de position.');
      return;
    }
    final requete = ++_requete;
    setState(() => _calcul = true);
    try {
      final it = await ItineraireService.calculer(
        depart,
        LatLng(b.latitude, b.longitude),
        aPied: _aPied,
      );
      if (!mounted || requete != _requete) return;
      setState(() => _itineraire = it);
      _cadrer(it);
    } catch (e) {
      if (!mounted || requete != _requete) return;
      setState(() => _erreurItineraire = e.toString());
    } finally {
      if (mounted && requete == _requete) setState(() => _calcul = false);
    }
  }

  void _effacer() {
    _requete++;
    setState(() {
      _cible = null;
      _itineraire = null;
      _erreurItineraire = null;
      _calcul = false;
    });
  }

  void _changerMode(bool aPied) {
    if (_aPied == aPied) return;
    setState(() => _aPied = aPied);
    if (_cible != null) _tracer(_cible!);
  }

  Future<void> _centrerSurMoi() async {
    await _controller.localiser();
    if (!mounted) return;
    final p = _controller.position;
    if (p == null) return;
    _deplacer(p, 16);
    final cible = _cible ?? _controller.plusProche;
    if (cible != null) await _tracer(cible);
  }

  Color _couleur(String etat) {
    final e = etat.toLowerCase();
    if (e == 'disponible') return const Color(0xFF27AE60);
    if (e == 'plein') return const Color(0xFFB3261E);
    return Colors.orange;
  }

  String _distance(double m) =>
      m < 1000 ? '${m.round()} m' : '${(m / 1000).toStringAsFixed(1)} km';

  String _duree(double s) {
    final minutes = (s / 60).round();
    if (minutes < 60) return '$minutes min';
    return '${minutes ~/ 60} h ${minutes % 60} min';
  }

  Widget _panneau() {
    final cible = _cible;
    final it = _itineraire;
    if (cible == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text("Touche un bac pour afficher l'itinéraire."),
        ),
      );
    }
    final detail = cible.zoneNom.isEmpty ? cible.etat : '${cible.zoneNom} · ${cible.etat}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.delete_outline, color: _couleur(cible.etat)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bac ${cible.code}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        detail,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Fermer',
                  icon: const Icon(Icons.close),
                  onPressed: _effacer,
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (_calcul)
              const Text("Calcul de l'itinéraire…")
            else if (_erreurItineraire != null) ...[
              Text(
                _erreurItineraire!,
                style: const TextStyle(color: Color(0xFFB3261E)),
              ),
              TextButton(
                onPressed: () => _tracer(cible),
                child: const Text('Réessayer'),
              ),
            ] else if (it != null)
              Text(
                '${_distance(it.distanceM)} · ${_duree(it.dureeS)} ${_aPied ? "à pied" : "en voiture"}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF14532D),
                ),
              ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  avatar: const Icon(Icons.directions_walk, size: 18),
                  label: const Text('À pied'),
                  selected: _aPied,
                  onSelected: (_) => _changerMode(true),
                ),
                ChoiceChip(
                  avatar: const Icon(Icons.directions_car, size: 18),
                  label: const Text('En voiture'),
                  selected: !_aPied,
                  onSelected: (_) => _changerMode(false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF27AE60),
        title: const Text('Carte des bacs', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _demarrer,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF27AE60),
        onPressed: _centrerSurMoi,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final it = _itineraire;
          final message = _controller.messageErreur ?? _controller.messagePosition;
          return Stack(
            children: [
              FlutterMap(
                mapController: _map,
                options: const MapOptions(
                  initialCenter: _centreParDefaut,
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.clean237_frontend',
                  ),
                  if (it != null)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: it.points,
                          strokeWidth: 6,
                          color: const Color(0xFF2355C7),
                          borderStrokeWidth: 2,
                          borderColor: Colors.white,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      for (final b in _controller.bacs)
                        Marker(
                          point: LatLng(b.latitude, b.longitude),
                          width: 46,
                          height: 46,
                          child: GestureDetector(
                            onTap: () => _tracer(b),
                            child: Icon(
                              Icons.delete_outline,
                              color: _couleur(b.etat),
                              size: _cible?.id == b.id ? 44 : 34,
                            ),
                          ),
                        ),
                      if (_controller.position != null)
                        Marker(
                          point: _controller.position!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.my_location,
                            color: Color(0xFF2355C7),
                            size: 32,
                          ),
                        ),
                    ],
                  ),
                  const RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('© OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
              if (_controller.enChargement)
                const Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (message != null)
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: Card(
                    color: const Color(0xFFFDECEA),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        message,
                        style: const TextStyle(color: Color(0xFFB3261E)),
                      ),
                    ),
                  ),
                ),
              Positioned(left: 16, right: 88, bottom: 16, child: _panneau()),
            ],
          );
        },
      ),
    );
  }
}
