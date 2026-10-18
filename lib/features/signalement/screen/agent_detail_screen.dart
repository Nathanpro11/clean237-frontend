import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/signalement_controller.dart';
import '../models/signalement_model.dart';
import '../widgets/statut_badge.dart';

class AgentDetailScreen extends StatelessWidget {
  final Signalement signalement;
  const AgentDetailScreen({super.key, required this.signalement});

  Future<void> _rejeter(
    BuildContext context,
    SignalementController controller,
  ) async {
    final motifController = TextEditingController();
    final motif = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Motif du rejet'),
        content: TextField(
          controller: motifController,
          decoration: const InputDecoration(hintText: 'Ex : photo illisible'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, motifController.text.trim()),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    if (motif != null && motif.isNotEmpty && context.mounted) {
      final ok = await controller.changerStatutAgent(
        signalement.id,
        'rejete',
        motifRejet: motif,
      );
      if (ok && context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SignalementController>(
      context,
      listen: false,
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF27AE60),
        title: const Text(
          'Rapport detaille',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(signalement.description, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 10),
            Text(
              '${signalement.quartier}${signalement.precision != null ? " - ${signalement.precision}" : ""}',
            ),
            const SizedBox(height: 10),
            StatutBadge(statut: signalement.statut),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                ),
                onPressed: () async {
                  final ok = await controller.changerStatutAgent(
                    signalement.id,
                    'pris_en_charge',
                  );
                  if (ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Statut mis à jour'),
                        backgroundColor: Color(0xFF27AE60),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Prendre en charge',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2355C7),
                ),
                onPressed: () async {
                  final ok = await controller.changerStatutAgent(
                    signalement.id,
                    'resolu',
                  );
                  if (ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Statut mis à jour'),
                        backgroundColor: Color(0xFF27AE60),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Marquer resolu',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFB3261E)),
                ),
                onPressed: () => _rejeter(context, controller),
                child: const Text(
                  'Rejeter',
                  style: TextStyle(color: Color(0xFFB3261E)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
