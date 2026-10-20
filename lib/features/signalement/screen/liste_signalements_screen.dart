import '../widgets/bouton_retour_accueil.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/signalement_controller.dart';
import '../models/signalement_model.dart';
import '../widgets/statut_badge.dart';
import 'creer_signalement_screen.dart';
import 'detail_signalement_screen.dart';

class ListeSignalementsScreen extends StatefulWidget {
  const ListeSignalementsScreen({super.key});
  @override
  State<ListeSignalementsScreen> createState() =>
      _ListeSignalementsScreenState();
}

class _ListeSignalementsScreenState extends State<ListeSignalementsScreen> {
  String filtre = 'Tous';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<SignalementController>(
        context,
        listen: false,
      ).chargerMesSignalements(),
    );
  }

  List<Signalement> filtrer(List<Signalement> liste) {
    if (filtre == 'En attente')
      return liste.where((s) => s.statut == 'en_attente').toList();
    if (filtre == 'Terminés')
      return liste
          .where((s) => s.statut == 'resolu' || s.statut == 'rejete')
          .toList();
    return liste;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BoutonRetourAccueil(),
        backgroundColor: const Color(0xFF27AE60),
        title: const Text(
          'Mes signalements',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Consumer<SignalementController>(
        builder: (context, controller, child) {
          if (controller.enChargement)
            return const Center(child: CircularProgressIndicator());
          final liste = filtrer(controller.mesSignalementsListe);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: ['Tous', 'En attente', 'Terminés'].map((f) {
                    final actif = filtre == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: actif,
                        selectedColor: const Color(0xFF27AE60),
                        labelStyle: TextStyle(
                          color: actif ? Colors.white : Colors.black87,
                        ),
                        onSelected: (_) => setState(() => filtre = f),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: liste.isEmpty
                    ? const Center(child: Text('Aucun signalement'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: liste.length,
                        itemBuilder: (context, i) {
                          final s = liste[i];
                          return Card(
                            color: const Color(0xFFF5F6F4),
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailSignalementScreen(
                                    signalementId: s.id,
                                  ),
                                ),
                              ),
                              title: Text(
                                s.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(s.quartier),
                              trailing: StatutBadge(statut: s.statut),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF27AE60),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreerSignalementScreen()),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
