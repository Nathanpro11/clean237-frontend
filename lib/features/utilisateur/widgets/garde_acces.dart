import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/features/utilisateur/controller/auth_controller.dart';
import 'package:clean237_frontend/features/utilisateur/screen/accueil_screen.dart';
import 'package:clean237_frontend/features/utilisateur/screen/admin_dashboard_screen.dart';
import 'package:clean237_frontend/features/utilisateur/screen/connexion_screen.dart';
import 'package:clean237_frontend/features/utilisateur/screen/dashboard_screen.dart';

/// Garde d'accès : le contenu protégé n'est construit que si
///   1. une session valide existe (utilisateur connecté, JWT non expiré) ;
///   2. le rôle lu dans le JWT fait partie de [rolesAutorises].
/// [rolesAutorises] vide == n'importe quel rôle connecté est admis
/// (pour les écrans communs comme Profil ou Historique).
/// Sinon : écran de connexion, ou écran "accès refusé".
///
/// Note : c'est une protection d'interface. Le vrai contrôle d'accès reste
/// celui du backend, qui doit vérifier le JWT et le rôle sur chaque route.
class GardeAcces extends StatelessWidget {
  final List<String> rolesAutorises;
  final Widget child;

  const GardeAcces({super.key, this.rolesAutorises = const [], required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    if (!auth.estConnecte) {
      return const ConnexionScreen();
    }

    if (rolesAutorises.isNotEmpty && !rolesAutorises.contains(auth.role)) {
      return const _AccesRefuse();
    }

    return child;
  }
}

class _AccesRefuse extends StatelessWidget {
  const _AccesRefuse();

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthController>();

    return Scaffold(
      backgroundColor: CleanCouleurs.blancPur,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 56, color: CleanCouleurs.rougeAlerte),
                  const SizedBox(height: 16),
                  const Text(
                    'Accès réservé',
                    style: TextStyle(
                      color: Color(0xFF14532D),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Votre compte n\'a pas les droits nécessaires pour accéder à cet espace.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final Widget accueil = switch (auth.role) {
                        'admin' => const AdminDashboardScreen(),
                        'agent' => const DashboardScreen(),
                        _ => const AccueilScreen(),
                      };
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => accueil),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CleanCouleurs.vertEco,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 0),
                    ),
                    child: const Text(
                      'Aller à mon espace',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      auth.logout();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const ConnexionScreen()),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Changer de compte',
                      style: TextStyle(color: CleanCouleurs.vertEco, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}