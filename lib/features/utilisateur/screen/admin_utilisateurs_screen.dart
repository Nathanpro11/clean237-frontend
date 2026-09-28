import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/features/utilisateur/controller/admin_controller.dart';
import 'package:clean237_frontend/features/utilisateur/models/utilisateur_model.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/garde_acces.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/panneau_utilisateur_admin.dart';

const Color _vertForet = Color(0xFF14532D);

/// Tableau des comptes du système + panneau latéral RBAC au clic sur une ligne.
class AdminUtilisateursScreen extends StatelessWidget {
  const AdminUtilisateursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GardeAcces(
      rolesAutorises: ['admin'],
      child: _AdminUtilisateursContenu(),
    );
  }
}

class _AdminUtilisateursContenu extends StatefulWidget {
  const _AdminUtilisateursContenu();

  @override
  State<_AdminUtilisateursContenu> createState() => _AdminUtilisateursContenuState();
}

class _AdminUtilisateursContenuState extends State<_AdminUtilisateursContenu> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AdminController>().chargerUtilisateurs();
    });
  }

  void _ouvrirPanneau(UtilisateurModel utilisateur) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fermer le panneau',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (contexteDialogue, animation, animationSecondaire) {
        return Align(
          alignment: Alignment.centerRight,
          child: PanneauUtilisateurAdmin(utilisateur: utilisateur),
        );
      },
      transitionBuilder: (contexteDialogue, animation, animationSecondaire, enfant) {
        final glissement = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return SlideTransition(position: glissement, child: enfant);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();
    final utilisateurs = admin.utilisateurs;

    return Scaffold(
      backgroundColor: CleanCouleurs.grisFond,
      appBar: AppBar(
        backgroundColor: CleanCouleurs.blancPur,
        elevation: 0,
        iconTheme: const IconThemeData(color: _vertForet),
        title: const Text(
          'Comptes et accès',
          style: TextStyle(color: _vertForet, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: utilisateurs.isEmpty
          ? Center(
              child: admin.enChargement
                  ? const CircularProgressIndicator(color: CleanCouleurs.vertEco)
                  : Text(admin.messageErreur ?? 'Aucun compte.'),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Touchez une ligne pour modifier le rôle, le statut et les permissions.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 12),
                _buildTableau(utilisateurs),
              ],
            ),
    );
  }

  Widget _buildTableau(List<UtilisateurModel> utilisateurs) {
    final largeurMin = MediaQuery.of(context).size.width - 32;

    return Container(
      decoration: BoxDecoration(
        color: CleanCouleurs.blancPur,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: largeurMin),
            child: DataTable(
              showCheckboxColumn: false,
              columnSpacing: 24,
              headingRowColor: WidgetStateProperty.all(CleanCouleurs.grisFond),
              headingTextStyle: const TextStyle(
                color: _vertForet,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              columns: const [
                DataColumn(label: Text('Nom')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Rôle')),
                DataColumn(label: Text('Statut')),
                DataColumn(label: Text('Actions')),
              ],
              rows: utilisateurs.map(_construireLigne).toList(),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _construireLigne(UtilisateurModel u) {
    return DataRow(
      onSelectChanged: (_) => _ouvrirPanneau(u),
      cells: [
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: CleanCouleurs.vertEco,
                child: Text(
                  u.nom.isNotEmpty ? u.nom[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Text(u.nom, style: const TextStyle(color: _vertForet, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
        DataCell(Text(u.email, style: const TextStyle(fontSize: 12, color: Colors.grey))),
        DataCell(_buildPuceRole(u.roleNom)),
        DataCell(_buildPuceStatut(u.estActif)),
        DataCell(
          IconButton(
            tooltip: 'Modifier les droits',
            icon: const Icon(Icons.tune, color: CleanCouleurs.vertEco, size: 20),
            onPressed: () => _ouvrirPanneau(u),
          ),
        ),
      ],
    );
  }

  Widget _buildPuceRole(String role) {
    final estAdmin = role == 'admin';
    final couleur = estAdmin ? const Color(0xFFDC143C) : _vertForet;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: couleur.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        libelleRoleAdmin(role),
        style: TextStyle(color: couleur, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPuceStatut(bool estActif) {
    final couleur = estActif ? CleanCouleurs.vertEco : Colors.grey;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: couleur, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          estActif ? 'Actif' : 'Désactivé',
          style: TextStyle(color: couleur, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}