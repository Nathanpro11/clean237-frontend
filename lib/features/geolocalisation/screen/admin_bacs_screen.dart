import 'package:flutter/material.dart';
import '../controller/geolocalisation_controller.dart';
import '../models/bac_model.dart';
import 'admin_bac_form_screen.dart';

class AdminBacsScreen extends StatefulWidget {
  const AdminBacsScreen({super.key});

  @override
  State<AdminBacsScreen> createState() => _AdminBacsScreenState();
}

class _AdminBacsScreenState extends State<AdminBacsScreen> {
  final _controller = GeolocalisationController();
  final _recherche = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.charger();
  }

  @override
  void dispose() {
    _controller.dispose();
    _recherche.dispose();
    super.dispose();
  }

  Color _couleur(String etat) {
    final e = etat.toLowerCase();
    if (e == 'disponible') return const Color(0xFF27AE60);
    if (e == 'plein') return const Color(0xFFB3261E);
    return Colors.orange;
  }

  Future<void> _ouvrirFormulaire([Bac? bac]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdminBacFormScreen(controller: _controller, bac: bac),
      ),
    );
  }

  Future<void> _supprimer(Bac b) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ce bac ?'),
        content: Text('Le bac ${b.code} sera supprimé définitivement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Color(0xFFB3261E))),
          ),
        ],
      ),
    );
    if (confirme != true) return;
    final succes = await _controller.supprimerBac(b.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(succes ? 'Bac supprimé' : (_controller.messageErreur ?? 'Erreur')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF27AE60),
        title: const Text('Bacs à ordure', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF27AE60),
        onPressed: () => _ouvrirFormulaire(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([_controller, _recherche]),
        builder: (context, _) {
          final filtre = _recherche.text.trim().toLowerCase();
          final liste = _controller.bacs
              .where((b) => b.code.toLowerCase().contains(filtre))
              .toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _recherche,
                  decoration: InputDecoration(
                    hintText: 'Rechercher par code',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFF5F6F4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (_controller.messageErreur != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _controller.messageErreur!,
                    style: const TextStyle(color: Color(0xFFB3261E)),
                  ),
                ),
              Expanded(
                child: _controller.enChargement
                    ? const Center(child: CircularProgressIndicator())
                    : liste.isEmpty
                        ? const Center(child: Text('Aucun bac pour le moment'))
                        : RefreshIndicator(
                            onRefresh: _controller.charger,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                              itemCount: liste.length,
                              itemBuilder: (context, i) {
                                final b = liste[i];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    onTap: () => _ouvrirFormulaire(b),
                                    leading: Icon(
                                      Icons.delete_outline,
                                      color: _couleur(b.etat),
                                      size: 32,
                                    ),
                                    title: Text('Bac ${b.code}'),
                                    subtitle: Text(
                                      '${b.zoneNom.isEmpty ? "Zone inconnue" : b.zoneNom} · ${b.etat}',
                                    ),
                                    trailing: IconButton(
                                      tooltip: 'Supprimer',
                                      icon: const Icon(
                                        Icons.delete_forever_outlined,
                                        color: Color(0xFFB3261E),
                                      ),
                                      onPressed: () => _supprimer(b),
                                    ),
                                  ),
                                );
                              },
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
