import 'package:flutter/material.dart';
import 'liste_signalements_screen.dart';
import 'notifications_screen.dart';

class CitoyenHomeScreen extends StatefulWidget {
  const CitoyenHomeScreen({super.key});
  @override
  State<CitoyenHomeScreen> createState() => _CitoyenHomeScreenState();
}

class _CitoyenHomeScreenState extends State<CitoyenHomeScreen> {
  int index = 0;
  final screens = const [ListeSignalementsScreen(), NotificationsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: const Color(0xFF27AE60),
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Signalements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}
