import '../widgets/bouton_retour_accueil.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/signalement_controller.dart';
import '../data/temps_ecoule.dart';
import 'notification_detail_screen.dart';

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
    final controller = Provider.of<SignalementController>(context);
    final liste = controller.notificationsListe;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BoutonRetourAccueil(),
        backgroundColor: const Color(0xFF27AE60),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (controller.notificationsNonLues > 0)
            IconButton(
              tooltip: 'Tout marquer comme lu',
              icon: const Icon(Icons.done_all, color: Colors.white),
              onPressed: controller.marquerToutesNotificationsLues,
            ),
        ],
      ),
      body: controller.enChargement && liste.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => controller.chargerNotifications(widget.destinataire),
              child: liste.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('Aucune notification')),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: liste.length,
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (context, i) {
                        final n = liste[i];
                        return ListTile(
                          tileColor: n.lu ? null : const Color(0xFFEAF7EF),
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
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            controller.marquerNotificationLue(n.id);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => NotificationDetailScreen(notification: n),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
    );
  }
}
