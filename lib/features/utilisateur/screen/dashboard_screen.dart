import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/utils/format_utils.dart';
import 'package:clean237_frontend/features/utilisateur/controller/auth_controller.dart';
import 'package:clean237_frontend/features/utilisateur/controller/agent_controller.dart';
import 'package:clean237_frontend/features/utilisateur/models/agent_stats_model.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/sidebar_menu.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/garde_acces.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/clean_bottom_nav.dart';

/// Tableau de bord de l'Agent de terrain. Pure View : tout vient d'AgentController (ViewModel),
/// donc du backend. Les missions et collectes seront ajoutées avec leur module.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GardeAcces(
      rolesAutorises: ['agent'],
      child: _DashboardContenu(),
    );
  }
}

class _DashboardContenu extends StatefulWidget {
  const _DashboardContenu();

  @override
  State<_DashboardContenu> createState() => _DashboardContenuState();
}

class _DashboardContenuState extends State<_DashboardContenu> {
  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    await Future<void>.delayed(Duration.zero);
    if (mounted) await context.read<AgentController>().chargerStats();
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = context.watch<AuthController>();
    final agentCtrl = context.watch<AgentController>();
    final nom = authCtrl.utilisateur?.nom.split(' ').first ?? 'Utilisateur';

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
              child: Image.asset('assets/logo.jpeg', width: 28, height: 28, fit: BoxFit.cover),
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
      bottomNavigationBar: const CleanBottomNav(currentIndex: 0),
      body: _buildCorps(agentCtrl),
    );
  }

  Widget _buildCorps(AgentController ctrl) {
    final stats = ctrl.stats;

    if (stats == null) {
      return Center(
        child: ctrl.enChargement
            ? const CircularProgressIndicator(color: CleanCouleurs.vertEco)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off_outlined, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    ctrl.messageErreur ?? 'Aucune donnée disponible.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _charger,
                    icon: const Icon(Icons.refresh, color: CleanCouleurs.vertEco, size: 18),
                    label: const Text('Réessayer', style: TextStyle(color: CleanCouleurs.vertEco)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: CleanCouleurs.vertEco)),
                  ),
                ],
              ),
      );
    }

    return RefreshIndicator(
      color: CleanCouleurs.vertEco,
      onRefresh: _charger,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _buildTitreSection('ESPACE AGENT DE TERRAIN'),
          const SizedBox(height: 10),
          _buildSecteurAgent(stats),
          const SizedBox(height: 14),
          _buildStatsAgent(stats),
          const SizedBox(height: 14),
          _buildInfoMissions(),
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

  Widget _buildSecteurAgent(AgentStatsModel stats) {
    final secteur = stats.secteurAffecte;
    final aSecteur = secteur != null && secteur.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CleanCouleurs.vertEco.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: CleanCouleurs.vertEco, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  aSecteur ? 'Secteur : ${capitaliserMots(secteur)}' : 'Aucun secteur assigné',
                  style: const TextStyle(
                    color: CleanCouleurs.anthracite,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (stats.matricule != null && stats.matricule!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.badge_outlined, color: CleanCouleurs.vertEco, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Matricule : ${stats.matricule}',
                  style: const TextStyle(color: CleanCouleurs.anthracite, fontSize: 13),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsAgent(AgentStatsModel stats) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CleanCouleurs.blancPur,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _chiffre("Connexions aujourd'hui", '${stats.connexionsAujourdHui}', CleanCouleurs.anthracite),
              ),
              Expanded(
                child: _chiffre('Actions enregistrées', '${stats.actionsEnregistrees}', CleanCouleurs.vertEco),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            stats.connexionPrecedente != null
                ? 'Connexion précédente : ${formaterDateHeure(stats.connexionPrecedente!)}'
                : 'Première connexion',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _chiffre(String libelle, String valeur, Color couleur) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(libelle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(valeur, style: TextStyle(color: couleur, fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInfoMissions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.grey, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Vos missions et collectes du jour seront affichées ici dès que le module missions sera activé.',
              style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}