import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/features/utilisateur/controller/auth_controller.dart';
import 'package:clean237_frontend/features/utilisateur/screen/connexion_screen.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/clean_bottom_nav.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/sidebar_menu.dart';

/// Écran Profil (module Utilisateur) : consultation et modification
/// des informations de base, changement de mot de passe, déconnexion.
class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = context.watch<AuthController>();
    final utilisateur = authCtrl.utilisateur;

    return Scaffold(
      backgroundColor: CleanCouleurs.grisFond,
      drawer: const SidebarMenu(),
      appBar: AppBar(
        backgroundColor: CleanCouleurs.blancPur,
        elevation: 0,
        iconTheme: const IconThemeData(color: CleanCouleurs.anthracite),
        title: const Text(
          'Mon Profil',
          style: TextStyle(color: CleanCouleurs.anthracite, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: utilisateur == null
          ? const Center(child: Text('Aucun utilisateur connecté.'))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildEnTeteProfil(context, utilisateur.nom, utilisateur.roleNom),
                const SizedBox(height: 24),
                _buildSectionInfos(context, utilisateur.nom, utilisateur.email, utilisateur.telephone),
                const SizedBox(height: 16),
                _buildSectionSecurite(context),
                const SizedBox(height: 16),
                _buildBoutonDeconnexion(context, authCtrl),
              ],
            ),
      bottomNavigationBar: const CleanBottomNav(currentIndex: 4),
    );
  }

  Widget _buildEnTeteProfil(BuildContext context, String nom, String role) {
    return Column(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: CleanCouleurs.vertEco,
          child: Text(
            nom.isNotEmpty ? nom[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        Text(nom, style: const TextStyle(color: CleanCouleurs.anthracite, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: CleanCouleurs.vertEco.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _libelleRole(role),
            style: const TextStyle(color: CleanCouleurs.vertEco, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
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

  Widget _buildSectionInfos(BuildContext context, String nom, String email, String telephone) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CleanCouleurs.blancPur,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Informations personnelles',
                style: TextStyle(color: CleanCouleurs.anthracite, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              TextButton.icon(
                onPressed: () => _ouvrirDialogueModifierProfil(context, nom, telephone),
                icon: const Icon(Icons.edit_outlined, size: 16, color: CleanCouleurs.vertEco),
                label: const Text('Modifier', style: TextStyle(color: CleanCouleurs.vertEco, fontSize: 12)),
              ),
            ],
          ),
          const Divider(height: 20),
          _ligneInfo(Icons.person_outline, 'Nom', nom),
          _ligneInfo(Icons.mail_outline, 'Email', email),
          _ligneInfo(Icons.phone_outlined, 'Téléphone', telephone),
        ],
      ),
    );
  }

  Widget _ligneInfo(IconData icone, String label, String valeur) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icone, color: Colors.grey, size: 18),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          Expanded(
            child: Text(
              valeur,
              style: const TextStyle(color: CleanCouleurs.anthracite, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSecurite(BuildContext context) {
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
        child: ListTile(
          leading: const Icon(Icons.lock_outline, color: CleanCouleurs.anthracite),
          title: const Text('Changer le mot de passe', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () => _ouvrirDialogueChangerMotDePasse(context),
        ),
      ),
    );
  }

  Widget _buildBoutonDeconnexion(BuildContext context, AuthController authCtrl) {
    return OutlinedButton.icon(
      onPressed: () {
        authCtrl.logout();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ConnexionScreen()),
          (route) => false,
        );
      },
      icon: const Icon(Icons.logout, color: CleanCouleurs.rougeAlerte),
      label: const Text('Se déconnecter', style: TextStyle(color: CleanCouleurs.rougeAlerte, fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: CleanCouleurs.rougeAlerte),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        minimumSize: const Size(double.infinity, 0),
      ),
    );
  }

  void _ouvrirDialogueModifierProfil(BuildContext context, String nomActuel, String telephoneActuel) {
    final nomController = TextEditingController(text: nomActuel);
    final telController = TextEditingController(text: telephoneActuel);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Modifier le profil'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomController,
                  decoration: const InputDecoration(labelText: 'Nom complet'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: telController,
                  decoration: const InputDecoration(labelText: 'Téléphone'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: CleanCouleurs.vertEco),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final authCtrl = context.read<AuthController>();
                  final succes = await authCtrl.modifierProfil(
                    nom: nomController.text.trim(),
                    telephone: telController.text.trim(),
                  );
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(succes ? 'Profil mis à jour !' : (authCtrl.messageErreur ?? 'Échec de la mise à jour')),
                        backgroundColor: succes ? CleanCouleurs.vertEco : CleanCouleurs.rougeAlerte,
                      ),
                    );
                  }
                }
              },
              child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _ouvrirDialogueChangerMotDePasse(BuildContext context) {
    final ancienController = TextEditingController();
    final nouveauController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Changer le mot de passe'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: ancienController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Ancien mot de passe'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nouveauController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
                  validator: (v) => (v == null || v.length < 6) ? '6 caractères min.' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: CleanCouleurs.vertEco),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final authCtrl = context.read<AuthController>();
                  final succes = await authCtrl.changerMotDePasse(
                    ancienMotDePasse: ancienController.text,
                    nouveauMotDePasse: nouveauController.text,
                  );
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(succes ? 'Mot de passe modifié !' : (authCtrl.messageErreur ?? 'Échec')),
                        backgroundColor: succes ? CleanCouleurs.vertEco : CleanCouleurs.rougeAlerte,
                      ),
                    );
                  }
                }
              },
              child: const Text('Confirmer', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}