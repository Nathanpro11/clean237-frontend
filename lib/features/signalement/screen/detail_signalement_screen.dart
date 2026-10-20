import '../widgets/contenu_adaptatif.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/signalement_controller.dart';
import '../data/signalement_service.dart';
import '../models/signalement_model.dart';
import '../widgets/statut_badge.dart';
import 'modifier_signalement_screen.dart';
import 'dart:io';

class DetailSignalementScreen extends StatefulWidget {
  final String signalementId;
  const DetailSignalementScreen({super.key, required this.signalementId});
  @override
  State<DetailSignalementScreen> createState() =>
      _DetailSignalementScreenState();
}

class _DetailSignalementScreenState extends State<DetailSignalementScreen> {
  Signalement? signalement;
  bool chargement = true;

  @override
  void initState() {
    super.initState();
    charger();
  }

  Future<void> charger() async {
    final s = await SignalementService().getSignalementParId(
      widget.signalementId,
    );
    setState(() {
      signalement = s;
      chargement = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (chargement)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final s = signalement!;
    final controller = Provider.of<SignalementController>(
      context,
      listen: false,
    );
    final modifiable = s.statut == 'en_attente';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF27AE60),
        title: const Text('Détail', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ContenuAdaptatif(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFF5F6F4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: s.photoUrl.startsWith('data:image')
                    ? Image.memory(base64Decode(s.photoUrl.split(',').last), fit: BoxFit.cover)
                    : s.photoUrl.startsWith('http')
                    ? Image.network(s.photoUrl, fit: BoxFit.cover)
                    : Image.file(
                        File(s.photoUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Center(child: Text('Photo indisponible')),
                      ),
              ),
            ),
            Text(s.description, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 12),
            Row(
              children: [
                StatutBadge(statut: s.statut),
                const SizedBox(width: 10),
                Text(
                  '${s.quartier}${s.precision != null && s.precision!.isNotEmpty ? " - ${s.precision}" : ""}',
                ),
              ],
            ),
            if (s.statut == 'rejete' && s.motifRejet != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFADBD8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Motif : ${s.motifRejet}',
                  style: const TextStyle(color: Color(0xFFB3261E)),
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (modifiable) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ModifierSignalementScreen(signalement: s),
                    ),
                  ).then((_) => Navigator.pop(context)),
                  child: const Text('Modifier'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB3261E),
                  ),
                  onPressed: () async {
                    final ok = await controller.annulerSignalement(s.id);
                    if (ok && context.mounted) Navigator.pop(context);
                  },
                  child: const Text(
                    'Annuler le signalement',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ] else
              const Text(
                'Modification et annulation possibles uniquement si le statut est "en attente"',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}
