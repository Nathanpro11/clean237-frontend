import 'package:clean237_frontend/features/utilisateur/widgets/sidebar_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/features/utilisateur/controller/auth_controller.dart';

/// Dashboard polymorphique : affiche la ou les sections adaptées au rôle
/// de l'utilisateur connecté (Admin / Agent terrain / Citoyen).
/// Basé sur la maquette dashboard-polymorphique.
/// Données FACTICES en attendant un vrai DashboardRepository.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = context.watch<AuthController>();
    final utilisateur = authCtrl.utilisateur;
    final role = utilisateur?.roleNom ?? 'citoyen';
    final nom = utilisateur?.nom.split(' ').first ?? 'Utilisateur';

    return Scaffold(
      backgroundColor: CleanCouleurs.grisFond,
      drawer: const SidebarMenu(),
      appBar: AppBar(
        backgroundColor: CleanCouleurs.blancPur,
        elevation: 0,
        iconTheme: const IconThemeData(color: CleanCouleurs.anthracite),
        title: Row(
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: CleanCouleurs.vertEco,
                  child: Text(
                    nom.isNotEmpty ? nom[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 6),
                Text(nom, style: const TextStyle(color: CleanCouleurs.anthracite, fontSize: 13)),
                const Icon(Icons.keyboard_arrow_down, color: CleanCouleurs.anthracite, size: 16),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🧪 Selon le pattern de la maquette : chaque bloc s'affiche
          // uniquement s'il concerne le rôle connecté.
          if (role == 'admin') ...[
            _buildTitreSection('ADMIN VIEW'),
            const SizedBox(height: 10),
            _buildStatsAdmin(),
            const SizedBox(height: 14),
            _buildBarreRecherche(),
            const SizedBox(height: 24),
          ],
          if (role == 'agent') ...[
            _buildTitreSection('FIELD AGENT VIEW'),
            const SizedBox(height: 10),
            _buildStatsAgent(),
            const SizedBox(height: 14),
            _buildSecteurAgent(),
            const SizedBox(height: 24),
          ],
          if (role == 'citoyen') ...[
            _buildTitreSection('CITIZEN VIEW'),
            const SizedBox(height: 10),
            _buildFideliteEcologique(),
            const SizedBox(height: 16),
            _buildBoutonSignaler(),
          ],
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

  Widget _buildStatsAdmin() {
    return Row(
      children: [
        Expanded(child: _buildCarteStat('5', 'Alertes critiques', Icons.warning_amber_rounded, Colors.red, fondRouge: true)),
        const SizedBox(width: 10),
        Expanded(child: _buildCarteStat('142', 'Plaintes urbaines', Icons.description_outlined, CleanCouleurs.anthracite)),
        const SizedBox(width: 10),
        Expanded(child: _buildCarteStat('18', 'Camions actifs', Icons.local_shipping_outlined, CleanCouleurs.vertEco)),
      ],
    );
  }

  Widget _buildCarteStat(String valeur, String label, IconData icone, Color couleur, {bool fondRouge = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fondRouge ? Colors.red.withOpacity(0.06) : CleanCouleurs.blancPur,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: fondRouge ? Colors.red.withOpacity(0.2) : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: couleur, size: 18),
          const SizedBox(height: 10),
          Text(valeur, style: TextStyle(color: couleur, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildBarreRecherche() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: CleanCouleurs.blancPur,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Rechercher une plainte, un secteur, un agent...',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsAgent() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CleanCouleurs.blancPur,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Missions aujourd\'hui', style: TextStyle(color: Colors.grey, fontSize: 11)),
                SizedBox(height: 4),
                Text('4', style: TextStyle(color: CleanCouleurs.anthracite, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Collectes terminées', style: TextStyle(color: Colors.grey, fontSize: 11)),
                SizedBox(height: 4),
                Text('3', style: TextStyle(color: CleanCouleurs.vertEco, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecteurAgent() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CleanCouleurs.vertEco.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: CleanCouleurs.vertEco, size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Secteur: Yaoundé VI', style: TextStyle(color: CleanCouleurs.anthracite, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildFideliteEcologique() {
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
            children: const [
              Text('Fidélité écologique', style: TextStyle(color: CleanCouleurs.anthracite, fontWeight: FontWeight.bold, fontSize: 14)),
              Text('150 Points', style: TextStyle(color: CleanCouleurs.vertEco, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.6,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(CleanCouleurs.vertEco),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.delete_outline, color: Colors.grey, size: 16),
              const SizedBox(width: 6),
              const Text('Dépôts signalés', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const Spacer(),
              const Text('2', style: TextStyle(color: CleanCouleurs.anthracite, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoutonSignaler() {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.add_box_outlined, color: Colors.white),
      label: const Text('Signaler un dépôt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: CleanCouleurs.vertEco,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        minimumSize: const Size(double.infinity, 0),
      ),
    );
  }
}