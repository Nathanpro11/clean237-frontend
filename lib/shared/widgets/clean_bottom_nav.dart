import 'package:clean237_frontend/features/dashboard/screen/accueil_screen.dart';
import 'package:clean237_frontend/features/historique/screen/historique_screen.dart';
import 'package:flutter/material.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/shared/screen/module_indisponible_screen.dart';
import 'package:clean237_frontend/features/utilisateur/screen/profil_screen.dart';

/// Barre de navigation commune à tous les écrans principaux :
/// Accueil, Collectes, Signaler, Historique, Profil.
/// Utilise pushReplacement pour éviter d'empiler les écrans indéfiniment.
class CleanBottomNav extends StatelessWidget {
  final int currentIndex;

  const CleanBottomNav({super.key, required this.currentIndex});

  void _naviguer(BuildContext context, int index) {
    if (index == currentIndex) return;

    late final Widget ecran;
    switch (index) {
      case 0:
        ecran = const AccueilScreen();
        break;
      case 1:
        ecran = const ModuleIndisponibleScreen(titre: 'Collectes', indexNavigation: 1);
        break;
      case 2:
        ecran = const ModuleIndisponibleScreen(titre: 'Signaler', indexNavigation: 2);
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
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _naviguer(context, index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: CleanCouleurs.vertEco,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), label: 'Collectes'),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Signaler'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
      ],
    );
  }
}