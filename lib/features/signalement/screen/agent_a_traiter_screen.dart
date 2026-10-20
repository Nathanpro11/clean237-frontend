import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/signalement_controller.dart';
import '../widgets/statut_badge.dart';
import 'agent_detail_screen.dart';

class AgentATraiterScreen extends StatefulWidget {
  const AgentATraiterScreen({super.key});
  @override
  State<AgentATraiterScreen> createState() => _AgentATraiterScreenState();
}

class _AgentATraiterScreenState extends State<AgentATraiterScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<SignalementController>(
        context,
        listen: false,
      ).chargerATraiter(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF27AE60),
        title: const Text('A traiter', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<SignalementController>(
        builder: (context, controller, child) {
          if (controller.enChargement)
            return const Center(child: CircularProgressIndicator());
          if (controller.aTraiterListe.isEmpty)
            return const Center(child: Text('Rien a traiter pour le moment'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.aTraiterListe.length,
            itemBuilder: (context, i) {
              final s = controller.aTraiterListe[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () {
                    Provider.of<SignalementController>(
                      context,
                      listen: false,
                    ).marquerSignalementConsulte(s.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AgentDetailScreen(signalement: s),
                      ),
                    ).then((_) => controller.chargerATraiter());
                  },
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
