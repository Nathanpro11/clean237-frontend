import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/signalement_controller.dart';
import '../data/temps_ecoule.dart';

class NotificationsScreen extends StatefulWidget {
  final String destinataire;
  const NotificationsScreen({super.key, required this.destinataire});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<SignalementController>(
        context,
        listen: false,
      ).chargerNotifications(widget.destinataire),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF27AE60),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Consumer<SignalementController>(
        builder: (context, controller, child) {
          if (controller.enChargement)
            return const Center(child: CircularProgressIndicator());
          if (controller.notificationsListe.isEmpty)
            return const Center(child: Text('Aucune notification'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notificationsListe.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final n = controller.notificationsListe[i];
              return ListTile(
                leading: Icon(
                  n.lu ? Icons.notifications_none : Icons.notifications_active,
                  color: n.lu ? Colors.grey : const Color(0xFF27AE60),
                ),
                title: Text(
                  n.message,
                  style: TextStyle(
                    fontWeight: n.lu ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text(tempsEcoule(n.dateEnvoi)),
                onTap: () => controller.chargerNotifications('citoyen'),
              );
            },
          );
        },
      ),
    );
  }
}
