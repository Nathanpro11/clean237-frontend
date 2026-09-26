import 'package:clean237_frontend/features/utilisateur/screen/historique_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/features/utilisateur/controller/auth_controller.dart';
import 'package:clean237_frontend/features/utilisateur/screen/connexion_screen.dart';

/// Menu latéral (Drawer), basé sur la maquette sidebar-menu.
/// Utilisé par tous les écrans principaux (Accueil, Dashboard, Profil...).
class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = context.watch<AuthController>();
    final utilisateur = authCtrl.utilisateur;
    final nom = utilisateur?.nom ?? 'Utilisateur';
    final role = utilisateur?.roleNom ?? '';

    return Drawer(
      backgroundColor: CleanCouleurs.blancPur,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/logo.jpeg',
                          width: 28,
                          height: 28,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Clean237',
                        style: TextStyle(color: CleanCouleurs.anthracite, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: CleanCouleurs.vertEco,
                    child: Text(
                      nom.isNotEmpty ? nom[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nom,
                        style: const TextStyle(color: CleanCouleurs.anthracite, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        role.isNotEmpty ? _libelleRole(role) : '',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildItemMenu(context, Icons.person_outline, 'Compte', actif: true, onTap: () => Navigator.pop(context)),
            _buildItemMenu(context, Icons.access_time, "Historique d'activité", onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const HistoriqueScreen()),
              );
            }),
            _buildItemMenu(context, Icons.location_on_outlined, 'Secteurs de Collecte', onTap: () => Navigator.pop(context)),
            _buildItemMenu(context, Icons.settings_outlined, 'Paramètres', onTap: () => Navigator.pop(context)),
            _buildItemMenu(context, Icons.help_outline, 'Aide & Support', onTap: () => Navigator.pop(context)),
            const Spacer(),
            const Divider(height: 1),
            _buildItemMenu(
              context,
              Icons.logout,
              'Se déconnecter',
              couleur: CleanCouleurs.rougeAlerte,
              onTap: () {
                authCtrl.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const ConnexionScreen()),
                  (route) => false,
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Clean237 App v1.4.2',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _libelleRole(String role) {
    switch (role) {
      case 'agent':
        return 'Agent de Terrain';
      case 'admin':
        return 'Administrateur';
      default:
        return 'Citoyen';
    }
  }

  Widget _buildItemMenu(
    BuildContext context,
    IconData icone,
    String label, {
    bool actif = false,
    Color? couleur,
    required VoidCallback onTap,
  }) {
    final couleurFinale = couleur ?? (actif ? CleanCouleurs.vertEco : CleanCouleurs.anthracite);
    return ListTile(
      leading: Icon(icone, color: couleurFinale, size: 20),
      title: Text(
        label,
        style: TextStyle(color: couleurFinale, fontSize: 14, fontWeight: actif ? FontWeight.bold : FontWeight.normal),
      ),
      trailing: actif ? Container(width: 3, height: 20, color: CleanCouleurs.vertEco) : null,
      onTap: onTap,
    );
  }
}