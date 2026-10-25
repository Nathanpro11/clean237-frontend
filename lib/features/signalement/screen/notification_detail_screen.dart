import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/signalement_controller.dart';
import '../data/temps_ecoule.dart';
import '../models/notification_model.dart';
import '../models/signalement_model.dart';
import '../widgets/statut_badge.dart';
import '../../geolocalisation/widgets/mini_carte.dart';

class NotificationDetailScreen extends StatefulWidget {
  final AppNotification notification;
  const NotificationDetailScreen({super.key, required this.notification});

  @override
  State<NotificationDetailScreen> createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  Signalement? _signalement;
  bool _chargement = false;

  @override
  void initState() {
    super.initState();
    final id = widget.notification.signalementId;
    if (id != null && id.isNotEmpty) {
      _chargement = true;
      _charger(id);
    }
  }

  Future<void> _charger(String id) async {
    final s = await Provider.of<SignalementController>(context, listen: false)
        .chargerSignalement(id);
    if (!mounted) return;
    setState(() {
      _signalement = s;
      _chargement = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.notification;
    final s = _signalement;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF27AE60),
        title: const Text('Détail', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active, color: Color(0xFF27AE60)),
                const SizedBox(width: 8),
                Text(tempsEcoule(n.dateEnvoi), style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              n.message,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (n.signalementId != null) ...[
              const Divider(height: 32),
              const Text(
                'Signalement concerné',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 12),
              if (_chargement)
                const Center(child: CircularProgressIndicator())
              else if (s == null)
                const Text("Ce signalement n'est plus disponible.")
              else ...[
                if (s.photoUrl.startsWith('data:image'))
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      base64Decode(s.photoUrl.split(',').last),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 10),
                Text(s.description, style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 10),
                Text(
                  '${s.quartier}${s.precision != null && s.precision!.isNotEmpty ? " - ${s.precision}" : ""}',
                ),
                const SizedBox(height: 10),
                StatutBadge(statut: s.statut),
                if (s.statut == 'rejete' && s.motifRejet != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Motif du rejet : ${s.motifRejet}',
                    style: const TextStyle(color: Color(0xFFB3261E)),
                  ),
                ],
                if (s.aUnePosition) ...[
                  const SizedBox(height: 12),
                  MiniCarte(latitude: s.latitude!, longitude: s.longitude!),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }
}
