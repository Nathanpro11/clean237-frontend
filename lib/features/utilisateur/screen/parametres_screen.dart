import 'package:flutter/material.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';

/// Écran Paramètres (module Utilisateur).
/// Préférences locales uniquement pour l'instant (pas encore persistées côté backend).
class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  bool _notificationsPush = true;
  bool _notificationsEmail = false;
  bool _localisationActive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CleanCouleurs.grisFond,
      appBar: AppBar(
        backgroundColor: CleanCouleurs.blancPur,
        elevation: 0,
        iconTheme: const IconThemeData(color: CleanCouleurs.anthracite),
        title: const Text(
          'Paramètres',
          style: TextStyle(color: CleanCouleurs.anthracite, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildTitreSection('NOTIFICATIONS'),
          const SizedBox(height: 8),
          _buildCarteOptions([
            _buildSwitchTile(
              icone: Icons.notifications_outlined,
              titre: 'Notifications push',
              sousTitre: 'Alertes sur les missions et collectes',
              valeur: _notificationsPush,
              onChanged: (v) => setState(() => _notificationsPush = v),
            ),
            _buildSwitchTile(
              icone: Icons.mail_outline,
              titre: 'Notifications par email',
              sousTitre: 'Résumés hebdomadaires par email',
              valeur: _notificationsEmail,
              onChanged: (v) => setState(() => _notificationsEmail = v),
            ),
          ]),
          const SizedBox(height: 24),
          _buildTitreSection('CONFIDENTIALITÉ'),
          const SizedBox(height: 8),
          _buildCarteOptions([
            _buildSwitchTile(
              icone: Icons.location_on_outlined,
              titre: 'Localisation',
              sousTitre: 'Nécessaire pour le suivi des collectes',
              valeur: _localisationActive,
              onChanged: (v) => setState(() => _localisationActive = v),
            ),
          ]),
          const SizedBox(height: 24),
          _buildTitreSection('GÉNÉRAL'),
          const SizedBox(height: 8),
          _buildCarteOptions([
            _buildNavTile(
              icone: Icons.language_outlined,
              titre: 'Langue',
              valeurActuelle: 'Français',
              onTap: () {},
            ),
            _buildNavTile(
              icone: Icons.delete_sweep_outlined,
              titre: 'Vider le cache',
              valeurActuelle: null,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache vidé.'), backgroundColor: CleanCouleurs.vertEco),
                );
              },
            ),
          ]),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Clean237 App v1.4.2',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitreSection(String titre) {
    return Text(
      titre,
      style: const TextStyle(color: CleanCouleurs.vertEco, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
    );
  }

  Widget _buildCarteOptions(List<Widget> enfants) {
    return Container(
      decoration: BoxDecoration(
        color: CleanCouleurs.blancPur,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: Column(children: enfants),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icone,
    required String titre,
    required String sousTitre,
    required bool valeur,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icone, color: CleanCouleurs.anthracite),
      title: Text(titre, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(sousTitre, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      value: valeur,
      activeColor: CleanCouleurs.vertEco,
      onChanged: onChanged,
    );
  }

  Widget _buildNavTile({
    required IconData icone,
    required String titre,
    required String? valeurActuelle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icone, color: CleanCouleurs.anthracite),
      title: Text(titre, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (valeurActuelle != null)
            Text(valeurActuelle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }
}