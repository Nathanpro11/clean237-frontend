import 'package:flutter/material.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/shared/widgets/clean_bottom_nav.dart';

/// Écran générique affiché pour les modules développés par d'autres membres
/// de l'équipe (Collectes, Signaler...) et pas encore intégrés dans cette branche.
class ModuleIndisponibleScreen extends StatelessWidget {
  final String titre;
  final int indexNavigation;

  const ModuleIndisponibleScreen({
    super.key,
    required this.titre,
    required this.indexNavigation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CleanCouleurs.grisFond,
      appBar: AppBar(
        backgroundColor: CleanCouleurs.blancPur,
        elevation: 0,
        iconTheme: const IconThemeData(color: CleanCouleurs.anthracite),
        title: Text(
          titre,
          style: const TextStyle(color: CleanCouleurs.anthracite, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction_outlined, color: Colors.grey.shade400, size: 64),
              const SizedBox(height: 20),
              Text(
                'Module « $titre »',
                textAlign: TextAlign.center,
                style: const TextStyle(color: CleanCouleurs.anthracite, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Pas encore disponible dans cette version.\nEn cours de développement par l'équipe.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CleanBottomNav(currentIndex: indexNavigation),
    );
  }
}