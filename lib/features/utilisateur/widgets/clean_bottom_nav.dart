import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/features/utilisateur/controller/auth_controller.dart';
import 'package:clean237_frontend/features/utilisateur/screen/accueil_screen.dart';
import 'package:clean237_frontend/features/utilisateur/screen/dashboard_screen.dart';
import 'package:clean237_frontend/features/utilisateur/screen/admin_dashboard_screen.dart';
import 'package:clean237_frontend/features/utilisateur/screen/historique_screen.dart';
import 'package:clean237_frontend/features/utilisateur/screen/module_indisponible_screen.dart';
import 'package:clean237_frontend/features/utilisateur/screen/profil_screen.dart';
import 'package:clean237_frontend/features/signalement/screen/citoyen_home_screen.dart';
import 'package:clean237_frontend/features/signalement/screen/agent_home_screen.dart';

/// Barre de navigation commune aux écrans principaux.
/// Index des onglets : 0 Accueil, 1 Collectes, 2 Signaler, 3 Historique, 4 Profil.
/// L'onglet "Accueil" s'adapte au rôle : citoyen -> AccueilScreen,
/// agent -> DashboardScreen, admin -> AdminDashboardScreen.
/// L'admin ne voit ni "Collectes" ni "Signaler" : il consulte les alertes et
/// les signalements depuis son propre tableau de bord.
/// Utilise pushReplacement pour éviter d'empiler les écrans indéfiniment.
class CleanBottomNav extends StatelessWidget {
  /// Index d'onglet de l'écran courant (0 à 4), même pour l'admin.
  final int currentIndex;

  const CleanBottomNav({super.key, required this.currentIndex});

  static const List<int> _ongletsTous = [0, 1, 2, 3, 4];
  static const List<int> _ongletsAdmin = [0, 3, 4];

  Widget _ecranAccueilPourRole(BuildContext context) {
    final role = context.read<AuthController>().role;
    return switch (role) {
      'admin' => const AdminDashboardScreen(),
      'agent' => const DashboardScreen(),
      _ => const AccueilScreen(),
    };
  }

  void _naviguer(BuildContext context, int index) {
    if (index == currentIndex) return;

    late final Widget ecran;
    switch (index) {
      case 0:
        ecran = _ecranAccueilPourRole(context);
        break;
      case 1:
        ecran = const ModuleIndisponibleScreen(titre: 'Collectes', indexNavigation: 1);
        break;
      case 2:
        final role = context.read<AuthController>().role;
        ecran = role == 'agent'
            ? const AgentHomeScreen()
            : role == 'admin'
                ? const ModuleIndisponibleScreen(titre: 'Signaler', indexNavigation: 2)
                : const CitoyenHomeScreen();
        break;
      case 3:
        ecran = const HistoriqueScreen();
        break;
      case 4:
      default:
        ecran = const ProfilScreen();
        break;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => ecran),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthController>().role;
    final visibles = role == 'admin' ? _ongletsAdmin : _ongletsTous;

    final items = <int, BottomNavigationBarItem>{
      0: const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Accueil'),
      1: const BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), label: 'Collectes'),
      2: const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Signaler'),
      3: const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique'),
      4: const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
    };

    final position = visibles.indexOf(currentIndex);

    return BottomNavigationBar(
      currentIndex: position < 0 ? 0 : position,
      onTap: (position) => _naviguer(context, visibles[position]),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: CleanCouleurs.vertEco,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: [for (final index in visibles) items[index]!],
    );
  }
}
