import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/utils/format_utils.dart';
import 'package:clean237_frontend/features/utilisateur/controller/auth_controller.dart';
import 'package:clean237_frontend/features/utilisateur/controller/citoyen_controller.dart';
import 'package:clean237_frontend/features/utilisateur/models/citoyen_stats_model.dart';
import 'package:clean237_frontend/features/utilisateur/screen/module_indisponible_screen.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/clean_bottom_nav.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/garde_acces.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/sidebar_menu.dart';
import 'package:clean237_frontend/features/signalement/screen/citoyen_home_screen.dart';

/// Écran d'accueil (vue Citoyen). Toutes les valeurs affichées viennent du backend.
/// Les signalements, collectes et points de fidélité seront ajoutés avec leurs modules :
/// d'ici là, aucune donnée inventée n'est affichée.
class AccueilScreen extends StatelessWidget {
  const AccueilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GardeAcces(
      rolesAutorises: ['citoyen'],
      child: _AccueilContenu(),
    );
  }
}

class _AccueilContenu extends StatefulWidget {
  const _AccueilContenu();

  @override
  State<_AccueilContenu> createState() => _AccueilContenuState();
}

class _AccueilContenuState extends State<_AccueilContenu> {
  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    // Différé après le premier build (notifyListeners pendant le build est interdit).
    await Future<void>.delayed(Duration.zero);
    if (mounted) await context.read<CitoyenController>().chargerStats();
  }

  void _ouvrirModule(String titre, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ModuleIndisponibleScreen(titre: titre, indexNavigation: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = context.watch<AuthController>();
    final citoyenCtrl = context.watch<CitoyenController>();
    final nom = authCtrl.utilisateur?.nom.split(' ').first ?? 'Utilisateur';

    return Scaffold(
      backgroundColor: CleanCouleurs.grisFond,
      drawer: const SidebarMenu(),
      body: SafeArea(
        child: Column(
          children: [
            _buildEnTete(nom),
            Expanded(
              child: RefreshIndicator(
                color: CleanCouleurs.vertEco,
                onRefresh: _charger,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildActionsRapides(nom),
                      const SizedBox(height: 24),
                      _buildTitreSection('MON COMPTE'),
                      const SizedBox(height: 12),
                      _buildCarteCompte(citoyenCtrl),
                      const SizedBox(height: 24),
                      _buildTitreSection('MES COLLECTES'),
                      const SizedBox(height: 12),
                      _buildEtatVide(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CleanBottomNav(currentIndex: 0),
    );
  }

  Widget _buildEnTete(String nom) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      color: CleanCouleurs.blancPur,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: CleanCouleurs.anthracite),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/logo.jpeg', width: 32, height: 32, fit: BoxFit.cover),
              ),
              const SizedBox(width: 8),
              const Text(
                'Clean237',
                style: TextStyle(color: CleanCouleurs.anthracite, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: CleanCouleurs.vertEco,
                child: Text(
                  nom.isNotEmpty ? nom[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                nom,
                style: const TextStyle(color: CleanCouleurs.anthracite, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const Icon(Icons.keyboard_arrow_down, color: CleanCouleurs.anthracite, size: 18),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitreSection(String titre) {
    return Text(
      titre,
      style: const TextStyle(
        color: CleanCouleurs.vertEco,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildActionsRapides(String nom) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour, $nom 👋',
          style: const TextStyle(color: CleanCouleurs.anthracite, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Votre propreté, notre priorité',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildBoutonAction(
                Icons.add_box_outlined,
                'Signaler un dépôt',
                () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CitoyenHomeScreen())),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBoutonAction(
                Icons.local_shipping_outlined,
                'Mes collectes',
                () => _ouvrirModule('Collectes', 1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBoutonAction(
                Icons.star_outline,
                'Fidélité écologique',
                () => _ouvrirModule('Fidélité écologique', 0),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBoutonAction(IconData icone, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: CleanCouleurs.blancPur,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icone, color: CleanCouleurs.vertEco, size: 22),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: CleanCouleurs.anthracite, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarteCompte(CitoyenController ctrl) {
    final stats = ctrl.stats;

    Widget contenu;
    if (stats == null) {
      contenu = Center(
        child: ctrl.enChargement
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(color: CleanCouleurs.vertEco, strokeWidth: 2),
              )
            : Column(
                children: [
                  Text(
                    ctrl.messageErreur ?? 'Aucune donnée disponible.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _charger,
                    icon: const Icon(Icons.refresh, color: CleanCouleurs.vertEco, size: 18),
                    label: const Text('Réessayer', style: TextStyle(color: CleanCouleurs.vertEco)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: CleanCouleurs.vertEco)),
                  ),
                ],
              ),
      );
    } else {
      contenu = _buildLignesCompte(stats);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CleanCouleurs.blancPur,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: contenu,
    );
  }

  Widget _buildLignesCompte(CitoyenStatsModel stats) {
    return Column(
      children: [
        _ligneCompte(
          Icons.event_available_outlined,
          'Membre depuis',
          stats.membreDepuis != null ? formaterDate(stats.membreDepuis!) : '—',
        ),
        _ligneCompte(
          Icons.login,
          'Connexion précédente',
          stats.connexionPrecedente != null ? formaterDateHeure(stats.connexionPrecedente!) : 'Première connexion',
        ),
        _ligneCompte(
          Icons.history,
          "Activités enregistrées",
          '${stats.actionsEnregistrees}',
        ),
      ],
    );
  }

  Widget _ligneCompte(IconData icone, String label, String valeur) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icone, color: CleanCouleurs.vertEco, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          Text(
            valeur,
            style: const TextStyle(color: CleanCouleurs.anthracite, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildEtatVide() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CleanCouleurs.blancPur,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.local_shipping_outlined, size: 32, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          const Text(
            'Aucune collecte à afficher',
            style: TextStyle(color: CleanCouleurs.anthracite, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'Vos signalements et collectes apparaîtront ici dès que ce module sera activé.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}