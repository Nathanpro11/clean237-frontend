import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controller/geolocalisation_controller.dart';
import '../data/position_service.dart';
import '../models/bac_model.dart';

class AdminBacFormScreen extends StatefulWidget {
  final GeolocalisationController controller;
  final Bac? bac;
  const AdminBacFormScreen({super.key, required this.controller, this.bac});

  @override
  State<AdminBacFormScreen> createState() => _AdminBacFormScreenState();
}

class _AdminBacFormScreenState extends State<AdminBacFormScreen> {
  static const _etats = ['Disponible', 'Plein', 'Endommagé', 'Hors service'];
  static const _centreParDefaut = LatLng(3.848, 11.502); // Yaoundé

  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _longueur = TextEditingController();
  final _largeur = TextEditingController();
  final _contenance = TextEditingController();
  final _map = MapController();
  String _etat = 'Disponible';
  String? _zoneId;
  LatLng? _point;
  bool _enCours = false;
  bool _positionEnCours = false;

  String _nombre(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  double? _lire(String texte) =>
      double.tryParse(texte.trim().replaceAll(',', '.'));

  @override
  void initState() {
    super.initState();
    final b = widget.bac;
    if (b != null) {
      _code.text = b.code;
      _longueur.text = _nombre(b.longueur);
      _largeur.text = _nombre(b.largeur);
      _contenance.text = _nombre(b.contenance);
      _etat = b.etat;
      _zoneId = b.zoneId.isEmpty ? null : b.zoneId;
      _point = LatLng(b.latitude, b.longitude);
    }
    widget.controller.chargerZones();
  }

  @override
  void dispose() {
    _code.dispose();
    _longueur.dispose();
    _largeur.dispose();
    _contenance.dispose();
    _map.dispose();
    super.dispose();
  }

  void _message(String texte) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texte)));
  }

  String? _validerNombre(String? v) {
    final n = _lire(v ?? '');
    return (n == null || n <= 0) ? 'Nombre positif requis' : null;
  }

  Future<void> _maPosition() async {
    setState(() => _positionEnCours = true);
    try {
      final p = await PositionService.positionActuelle();
      if (!mounted) return;
      final pt = LatLng(p.latitude, p.longitude);
      setState(() => _point = pt);
      _map.move(pt, 16);
    } catch (e) {
      if (!mounted) return;
      _message(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _positionEnCours = false);
    }
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_zoneId == null) {
      _message('Choisis une zone');
      return;
    }
    if (_point == null) {
      _message('Choisis la position du bac sur la carte');
      return;
    }
    setState(() => _enCours = true);
    final donnees = <String, dynamic>{
      'code': _code.text.trim(),
      'longueur': _lire(_longueur.text),
      'largeur': _lire(_largeur.text),
      'contenance': _lire(_contenance.text),
      'etat': _etat,
      'latitude': _point!.latitude,
      'longitude': _point!.longitude,
      'zone': _zoneId,
    };
    final ok = widget.bac == null
        ? await widget.controller.creerBac(donnees)
        : await widget.controller.modifierBac(widget.bac!.id, donnees);
    if (!mounted) return;
    setState(() => _enCours = false);
    if (ok) {
      Navigator.pop(context, true);
    } else {
      _message(widget.controller.messageErreur ?? 'Erreur');
    }
  }

  InputDecoration _deco(String indice) => InputDecoration(
        hintText: indice,
        filled: true,
        fillColor: const Color(0xFFF5F6F4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  Widget _titre(String texte) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(texte, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  @override
  Widget build(BuildContext context) {
    final etats = {..._etats, _etat}.toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF27AE60),
        title: Text(
          widget.bac == null ? 'Nouveau bac' : 'Modifier le bac',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _titre('Code *'),
              TextFormField(
                controller: _code,
                decoration: _deco('Ex : BAC-010'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Le code est obligatoire'
                    : null,
              ),
              _titre('Longueur (m) *'),
              TextFormField(
                controller: _longueur,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _deco('Ex : 1.2'),
                validator: _validerNombre,
              ),
              _titre('Largeur (m) *'),
              TextFormField(
                controller: _largeur,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _deco('Ex : 0.8'),
                validator: _validerNombre,
              ),
              _titre('Contenance *'),
              TextFormField(
                controller: _contenance,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _deco('Ex : 240'),
                validator: _validerNombre,
              ),
              _titre('État'),
              DropdownButtonFormField<String>(
                initialValue: _etat,
                decoration: _deco(''),
                items: [
                  for (final e in etats) DropdownMenuItem(value: e, child: Text(e)),
                ],
                onChanged: (v) => setState(() => _etat = v ?? _etat),
              ),
              _titre('Zone *'),
              ListenableBuilder(
                listenable: widget.controller,
                builder: (context, _) {
                  final zones = widget.controller.zones;
                  if (zones.isEmpty) {
                    return const Text('Chargement des zones…');
                  }
                  final ids = zones.map((z) => z.id).toList();
                  return DropdownButtonFormField<String>(
                    initialValue: ids.contains(_zoneId) ? _zoneId : null,
                    decoration: _deco('Choisis une zone'),
                    items: [
                      for (final z in zones)
                        DropdownMenuItem(value: z.id, child: Text(z.nom)),
                    ],
                    onChanged: (v) => _zoneId = v,
                  );
                },
              ),
              _titre('Position du bac * (touche la carte)'),
              SizedBox(
                height: 260,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    mapController: _map,
                    options: MapOptions(
                      initialCenter: _point ?? _centreParDefaut,
                      initialZoom: _point == null ? 13 : 16,
                      onTap: (_, p) => setState(() => _point = p),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.clean237_frontend',
                      ),
                      MarkerLayer(
                        markers: [
                          if (_point != null)
                            Marker(
                              point: _point!,
                              width: 40,
                              height: 40,
                              alignment: Alignment.topCenter,
                              child: const Icon(
                                Icons.location_on,
                                color: Color(0xFFB3261E),
                                size: 40,
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
                ),
              ),
              const SizedBox(height: 8),
              if (_point != null)
                Text(
                  'Position : ${_point!.latitude.toStringAsFixed(5)}, ${_point!.longitude.toStringAsFixed(5)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _positionEnCours ? null : _maPosition,
                  icon: _positionEnCours
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location, color: Color(0xFF27AE60)),
                  label: const Text(
                    'Utiliser ma position',
                    style: TextStyle(color: Color(0xFF27AE60)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _enCours ? null : _enregistrer,
                  child: _enCours
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Enregistrer',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
