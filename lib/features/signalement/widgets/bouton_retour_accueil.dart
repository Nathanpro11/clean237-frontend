import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clean237_frontend/features/utilisateur/controller/auth_controller.dart';
import 'package:clean237_frontend/features/utilisateur/screen/accueil_screen.dart';
import 'package:clean237_frontend/features/utilisateur/screen/dashboard_screen.dart';
import 'package:clean237_frontend/features/utilisateur/screen/admin_dashboard_screen.dart';

/// Flèche de retour : revient à l'écran précédent, sinon à l'accueil du rôle.
class BoutonRetourAccueil extends StatelessWidget {
  const BoutonRetourAccueil({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Retour',
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          return;
        }
        final role = context.read<AuthController>().role;
        final Widget accueil = switch (role) {
          'admin' => const AdminDashboardScreen(),
          'agent' => const DashboardScreen(),
          _ => const AccueilScreen(),
        };
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => accueil));
      },
    );
  }
}
