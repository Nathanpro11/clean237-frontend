import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/signalement_controller.dart';
import 'agent_a_traiter_screen.dart';
import 'agent_historiques_screen.dart';
import 'notifications_screen.dart';

class AgentHomeScreen extends StatefulWidget {
  const AgentHomeScreen({super.key});
  @override
  State<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends State<AgentHomeScreen> {
  int index = 0;
  final screens = const [
    AgentATraiterScreen(),
    AgentHistoriqueScreen(),
    NotificationsScreen(destinataire: 'agent'),
  ];

  @override
  void initState() {
    super.initState();
    final c = Provider.of<SignalementController>(context, listen: false);
    Future.microtask(() {
      c.chargerATraiter();
      c.chargerNotifications('agent');
    });
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
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('${controller.signalementsNonConsultesCompteur}'),
              isLabelVisible: controller.signalementsNonConsultesCompteur > 0,
              child: const Icon(Icons.assignment_turned_in_outlined),
            ),
            label: 'A traiter',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historique',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('${controller.notificationsNonLuesCompteur}'),
              isLabelVisible: controller.notificationsNonLuesCompteur > 0,
              child: const Icon(Icons.notifications_outlined),
            ),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}
