import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/features/utilisateur/controller/parametres_controller.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/garde_acces.dart';

/// Écran Paramètres. Pure View : aucun état métier ici, tout vient de
/// ParametresController (ViewModel). Les switches reflètent l'état du
/// contrôleur et lui délèguent chaque changement.
class ParametresScreen extends StatelessWidget {
  const ParametresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GardeAcces(child: _ParametresContenu());
  }
}

class _ParametresContenu extends StatefulWidget {
  const _ParametresContenu();

  @override
  State<_ParametresContenu> createState() => _ParametresContenuState();
}

class _ParametresContenuState extends State<_ParametresContenu> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ParametresController>().chargerPreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ParametresController>();

    return Scaffold(
      backgroundColor: CleanCouleurs.grisFond,
      appBar: AppBar(
        backgroundColor: CleanCouleurs.blancPur,
        elevation: 0,
        iconTheme: const IconThemeData(color: CleanCouleurs.anthracite),
        title: const Text('Paramètres', style: TextStyle(color: CleanCouleurs.anthracite, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: _buildCorps(ctrl),
    );
  }

  Widget _buildCorps(ParametresController ctrl) {
    final prefs = ctrl.preferences;

    if (prefs == null) {
      return Center(
        child: ctrl.enChargement
            ? const CircularProgressIndicator(color: CleanCouleurs.vertEco)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(ctrl.messageErreur ?? 'Aucune donnée.', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => ctrl.chargerPreferences(),
                    icon: const Icon(Icons.refresh, color: CleanCouleurs.vertEco, size: 18),
                    label: const Text('Réessayer', style: TextStyle(color: CleanCouleurs.vertEco)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: CleanCouleurs.vertEco)),
                  ),
                ],
              ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildTitreSection('NOTIFICATIONS'),
        const SizedBox(height: 8),
        _buildCarteOptions([
          _buildSwitchTile(
            icone: Icons.notifications_outlined,
            titre: 'Notifications push',
            sousTitre: 'Alertes sur les missions et collectes',
            valeur: prefs.notificationsPush,
            onChanged: (v) => context.read<ParametresController>().basculerNotificationsPush(v),
          ),
          _buildSwitchTile(
            icone: Icons.mail_outline,
            titre: 'Notifications par email',
            sousTitre: 'Résumés hebdomadaires par email',
            valeur: prefs.notificationsEmail,
            onChanged: (v) => context.read<ParametresController>().basculerNotificationsEmail(v),
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
            valeur: prefs.localisationActive,
            onChanged: (v) => context.read<ParametresController>().basculerLocalisation(v),
          ),
        ]),
        const SizedBox(height: 24),
        _buildTitreSection('GÉNÉRAL'),
        const SizedBox(height: 8),
        _buildCarteOptions([
          _buildNavTile(icone: Icons.language_outlined, titre: 'Langue', valeurActuelle: 'Français', onTap: () {}),
          _buildNavTile(
            icone: Icons.delete_sweep_outlined,
            titre: 'Vider le cache',
            valeurActuelle: null,
            onTap: () async {
              await context.read<ParametresController>().viderCache();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache vidé.'), backgroundColor: CleanCouleurs.vertEco),
                );
              }
            },
          ),
        ]),
        const SizedBox(height: 24),
        const Center(child: Text('Clean237 App v1.4.2', style: TextStyle(color: Colors.grey, fontSize: 12))),
      ],
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
          if (valeurActuelle != null) Text(valeurActuelle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }
}