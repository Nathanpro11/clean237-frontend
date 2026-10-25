import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/itineraire_service.dart';
import '../data/position_service.dart';

/// Carte plein écran : trajet de la position du téléphone jusqu'à une destination.
class ItineraireScreen extends StatefulWidget {
  final LatLng destination;
  final String titre;
  const ItineraireScreen({super.key, required this.destination, required this.titre});

  @override
  State<ItineraireScreen> createState() => _ItineraireScreenState();
}

class _ItineraireScreenState extends State<ItineraireScreen> {
  final _map = MapController();
  LatLng? _depart;
  Itineraire? _itineraire;
  bool _aPied = true;
  bool _enCours = true;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _calculer();
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  Future<void> _calculer() async {
    setState(() {
      _enCours = true;
      _erreur = null;
    });
    try {
      if (_depart == null) {
        final p = await PositionService.positionActuelle();
        _depart = LatLng(p.latitude, p.longitude);
      }
      final it = await ItineraireService.calculer(
        _depart!,
        widget.destination,
        aPied: _aPied,
      );
      if (!mounted) return;
      setState(() => _itineraire = it);
      _cadrer(it);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _itineraire = null;
        _erreur = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  void _cadrer(Itineraire it) {
    try {
      _map.fitCamera(
        CameraFit.coordinates(
          coordinates: it.points,
          padding: const EdgeInsets.fromLTRB(40, 40, 40, 190),
        ),
      );
    } catch (_) {
      // La carte n'est pas encore prête : on garde le cadrage par défaut.
    }
  }

  String _distance(double m) =>
      m < 1000 ? '${m.round()} m' : '${(m / 1000).toStringAsFixed(1)} km';

  String _duree(double s) {
    final minutes = (s / 60).round();
    if (minutes < 60) return '$minutes min';
    return '${minutes ~/ 60} h ${minutes % 60} min';
  }

  void _changerMode(bool aPied) {
    if (_aPied == aPied) return;
    setState(() => _aPied = aPied);
    _calculer();
  }

  @override
  Widget build(BuildContext context) {
    final it = _itineraire;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF27AE60),
        title: Text(widget.titre, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(initialCenter: widget.destination, initialZoom: 15),
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
                  Marker(
                    point: widget.destination,
                    width: 40,
                    height: 40,
                    alignment: Alignment.topCenter,
                    child: const Icon(
                      Icons.location_on,
                      color: Color(0xFFB3261E),
                      size: 40,
                    ),
                  ),
                  if (_depart != null)
                    Marker(
                      point: _depart!,
                      width: 36,
                      height: 36,
                      child: const Icon(
                        Icons.my_location,
                        color: Color(0xFF2355C7),
                        size: 30,
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
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_enCours)
                      const Row(
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Calcul de l\'itinéraire…'),
                        ],
                      )
                    else if (_erreur != null) ...[
                      Text(_erreur!, style: const TextStyle(color: Color(0xFFB3261E))),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: _calculer,
                        child: const Text('Réessayer'),
                      ),
                    ] else if (it != null)
                      Text(
                        '${_distance(it.distanceM)} · ${_duree(it.dureeS)} ${_aPied ? "à pied" : "en voiture"}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF14532D),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ChoiceChip(
                          avatar: const Icon(Icons.directions_walk, size: 18),
                          label: const Text('À pied'),
                          selected: _aPied,
                          onSelected: (_) => _changerMode(true),
                        ),
                        const SizedBox(width: 8),
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
            ),
          ),
        ],
      ),
    );
  }
}
