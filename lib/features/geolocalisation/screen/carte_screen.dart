import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controller/geolocalisation_controller.dart';
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

  @override
  void initState() {
    super.initState();
    _controller.charger();
  }

  @override
  void dispose() {
    _controller.dispose();
    _map.dispose();
    super.dispose();
  }

  Color _couleur(String etat) {
    final e = etat.toLowerCase();
    if (e == 'disponible') return const Color(0xFF27AE60);
    if (e == 'plein') return const Color(0xFFB3261E);
    return Colors.orange;
  }

  Future<void> _centrerSurMoi() async {
    await _controller.localiser();
    if (!mounted) return;
    final p = _controller.position;
    if (p != null) {
      _map.move(p, 16);
    } else if (_controller.messagePosition != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.messagePosition!)),
      );
    }
  }

  void _details(Bac b) {
    final distance = _controller.distanceVers(b);
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bac ${b.code}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('État : ${b.etat}'),
            if (b.zoneNom.isNotEmpty) Text('Zone : ${b.zoneNom}'),
            Text('Contenance : ${b.contenance.toStringAsFixed(0)}'),
            if (distance != null) Text('Distance : $distance m'),
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
            onPressed: _controller.charger,
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
          final proche = _controller.plusProche;
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
                  MarkerLayer(
                    markers: [
                      for (final b in _controller.bacs)
                        Marker(
                          point: LatLng(b.latitude, b.longitude),
                          width: 44,
                          height: 44,
                          child: GestureDetector(
                            onTap: () => _details(b),
                            child: Icon(
                              Icons.delete_outline,
                              color: _couleur(b.etat),
                              size: 36,
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
              if (_controller.messageErreur != null)
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: Card(
                    color: const Color(0xFFFDECEA),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        _controller.messageErreur!,
                        style: const TextStyle(color: Color(0xFFB3261E)),
                      ),
                    ),
                  ),
                ),
              if (proche != null)
                Positioned(
                  left: 16,
                  right: 88,
                  bottom: 16,
                  child: Card(
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: _couleur(proche.etat)),
                      title: Text('Bac le plus proche : ${proche.code}'),
                      subtitle: Text('À ${_controller.distanceVers(proche)} m'),
                      onTap: () => _details(proche),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
