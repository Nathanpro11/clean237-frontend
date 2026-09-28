import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/features/utilisateur/controller/admin_controller.dart';
import 'package:clean237_frontend/features/utilisateur/repository/admin_repository.dart';
import 'package:clean237_frontend/features/utilisateur/screen/admin_utilisateurs_screen.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/garde_acces.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/graphique_tendance.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/sidebar_menu.dart';

const Color _vertForet = Color(0xFF14532D);
const Color _cramoisi = Color(0xFFDC143C);

/// Centre de supervision du Super-Admin (Mairie de Yaoundé VI).
/// Affiché après connexion quand le rôle lu dans le JWT est "admin".
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Connexion obligatoire + rôle admin, sinon l'écran n'est jamais construit.
    return const GardeAcces(
      rolesAutorises: ['admin'],
      child: _AdminDashboardContenu(),
    );
  }
}

class _AdminDashboardContenu extends StatefulWidget {
  const _AdminDashboardContenu();

  @override
  State<_AdminDashboardContenu> createState() => _AdminDashboardContenuState();
}

class _AdminDashboardContenuState extends State<_AdminDashboardContenu> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AdminController>().chargerTableauDeBord();
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();
    final stats = admin.stats;

    return Scaffold(
      backgroundColor: CleanCouleurs.grisFond,
      drawer: const SidebarMenu(),
      body: SafeArea(
        child: Column(
          children: [
            _buildRuban(),
            Expanded(
              child: stats == null
                  ? Center(
                      child: admin.enChargement
                          ? const CircularProgressIndicator(color: CleanCouleurs.vertEco)
                          : Text(admin.messageErreur ?? 'Aucune donnée disponible.'),
                    )
                  : _buildContenu(stats),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuban() {
    return Container(
      color: CleanCouleurs.blancPur,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: _vertForet),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/logo.jpeg', width: 28, height: 28, fit: BoxFit.cover),
          ),
          const SizedBox(width: 8),
          const Text(
            'Clean237',
            style: TextStyle(color: _vertForet, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: _cramoisi, borderRadius: BorderRadius.circular(20)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Text(
                  'Super-Admin',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildContenu(StatsAdmin stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Supervision municipale',
                style: TextStyle(color: _vertForet, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Mairie de Yaoundé VI · Gestion intelligente des déchets',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),
              _buildCartesScore(stats),
              const SizedBox(height: 24),
              _buildCarteGraphique(stats),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AdminUtilisateursScreen()),
                  );
                },
                icon: const Icon(Icons.admin_panel_settings_outlined, color: Colors.white),
                label: const Text(
                  'Gérer les comptes et les accès',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CleanCouleurs.vertEco,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartesScore(StatsAdmin stats) {
    return LayoutBuilder(
      builder: (context, contraintes) {
        const espace = 16.0;
        final colonnes = contraintes.maxWidth >= 640 ? 3 : 1;
        final largeurCarte = (contraintes.maxWidth - espace * (colonnes - 1)) / colonnes;

        return Wrap(
          spacing: espace,
          runSpacing: espace,
          children: [
            SizedBox(
              width: largeurCarte,
              child: _CarteScore(
                icone: Icons.analytics_outlined,
                valeur: '${stats.plaintesActives}',
                libelle: 'Plaintes urbaines actives',
              ),
            ),
            SizedBox(
              width: largeurCarte,
              child: _CarteScore(
                icone: Icons.local_shipping_outlined,
                valeur: '${stats.camionsActifs}',
                libelle: 'Camions actifs sur le terrain',
              ),
            ),
            SizedBox(
              width: largeurCarte,
              child: _CarteScore(
                icone: Icons.warning_amber_rounded,
                valeur: '${stats.alertesCritiques}',
                libelle: 'Alertes critiques d\'assainissement',
                critique: true,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCarteGraphique(StatsAdmin stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CleanCouleurs.blancPur,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Signalements par trimestre',
            style: TextStyle(color: _vertForet, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tendance par quartier, Yaoundé VI',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 20),
          GraphiqueTendance(
            etiquettes: stats.trimestres,
            series: stats.tendanceParQuartier,
            couleurs: const [CleanCouleurs.vertEco, _vertForet, Color(0xFF86B817)],
          ),
        ],
      ),
    );
  }
}

class _CarteScore extends StatelessWidget {
  final IconData icone;
  final String valeur;
  final String libelle;
  final bool critique;

  const _CarteScore({
    required this.icone,
    required this.valeur,
    required this.libelle,
    this.critique = false,
  });

  @override
  Widget build(BuildContext context) {
    final couleurAccent = critique ? CleanCouleurs.rougeAlerte : CleanCouleurs.vertEco;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: critique ? CleanCouleurs.rougeAlerte.withAlpha(15) : CleanCouleurs.blancPur,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: critique ? CleanCouleurs.rougeAlerte : Colors.grey.shade200,
          width: critique ? 1.8 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valeur,
                  style: TextStyle(
                    color: critique ? CleanCouleurs.rougeAlerte : _vertForet,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(libelle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Icon(icone, size: 36, color: couleurAccent),
        ],
      ),
    );
  }
}