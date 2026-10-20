import '../widgets/bouton_retour_accueil.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/signalement_controller.dart';
import '../widgets/statut_badge.dart';

class AgentHistoriqueScreen extends StatefulWidget {
  const AgentHistoriqueScreen({super.key});
  @override
  State<AgentHistoriqueScreen> createState() => _AgentHistoriqueScreenState();
}

class _AgentHistoriqueScreenState extends State<AgentHistoriqueScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<SignalementController>(
        context,
        listen: false,
      ).chargerHistoriqueAgent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BoutonRetourAccueil(),
        backgroundColor: const Color(0xFF27AE60),
        title: const Text('Historique', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<SignalementController>(
        builder: (context, controller, child) {
          if (controller.enChargement)
            return const Center(child: CircularProgressIndicator());
          if (controller.historiqueListe.isEmpty)
            return const Center(child: Text('Aucun signalement traite'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.historiqueListe.length,
            itemBuilder: (context, i) {
              final s = controller.historiqueListe[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
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
          );
        },
      ),
    );
  }
}
