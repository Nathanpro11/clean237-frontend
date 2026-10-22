import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/signalement_controller.dart';
import '../../geolocalisation/screen/carte_screen.dart';
import 'liste_signalements_screen.dart';
import 'notifications_screen.dart';

class CitoyenHomeScreen extends StatefulWidget {
  const CitoyenHomeScreen({super.key});
  @override
  State<CitoyenHomeScreen> createState() => _CitoyenHomeScreenState();
}

class _CitoyenHomeScreenState extends State<CitoyenHomeScreen> {
  int index = 0;
  final screens = const [
    ListeSignalementsScreen(),
    CarteScreen(),
    NotificationsScreen(destinataire: 'citoyen'),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<SignalementController>(
        context,
        listen: false,
      ).chargerNotifications('citoyen'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SignalementController>(context);
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: const Color(0xFF27AE60),
        onTap: (i) => setState(() => index = i),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Signalements',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Carte',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('${controller.notificationsNonLues}'),
              isLabelVisible: controller.notificationsNonLues > 0,
              child: const Icon(Icons.notifications_outlined),
            ),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}
