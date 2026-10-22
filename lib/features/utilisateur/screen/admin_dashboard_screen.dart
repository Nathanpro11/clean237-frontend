import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clean237_frontend/common/navigator/app_routes.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/features/utilisateur/controller/admin_controller.dart';
import 'package:clean237_frontend/features/utilisateur/repository/admin_repository.dart';
import 'package:clean237_frontend/features/utilisateur/screen/admin_module_screen.dart';
import 'package:clean237_frontend/features/utilisateur/screen/admin_utilisateurs_screen.dart';
import 'package:clean237_frontend/features/geolocalisation/screen/admin_bacs_screen.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/garde_acces.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/sidebar_menu.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/clean_bottom_nav.dart';

const Color _vertForet = Color(0xFF14532D);
const Color _cramoisi = Color(0xFFDC143C);

/// Centre de supervision du Super-Admin (Mairie de Yaoundé VI).
/// Indicateurs RÉELS calculés par le backend (comptes + journal d'audit).
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
    _charger();
  }

  Future<void> _charger() async {
    await Future<void>.delayed(Duration.zero);
    if (mounted) await context.read<AdminController>().chargerTableauDeBord();
  }

  void _ouvrirModule(String route) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AdminModuleScreen(routeInitiale: route)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();
    final stats = admin.stats;

    return Scaffold(
      backgroundColor: CleanCouleurs.grisFond,
      drawer: const SidebarMenu(),
      bottomNavigationBar: const CleanBottomNav(currentIndex: 0),
      body: SafeArea(
        child: Column(
          children: [
            _buildRuban(),
            Expanded(
              child: stats == null
                  ? Center(
                      child: admin.enChargement
                          ? const CircularProgressIndicator(color: CleanCouleurs.vertEco)
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.wifi_off_outlined, size: 40, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  admin.messageErreur ?? 'Aucune donnée disponible.',
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
                    )
                  : RefreshIndicator(
                      color: CleanCouleurs.vertEco,
                      onRefresh: _charger,
                      child: _buildContenu(stats),
                    ),
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
      physics: const AlwaysScrollableScrollPhysics(),
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
              const SizedBox(height: 16),
              _buildInfoModules(),
              const SizedBox(height: 24),
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
              const SizedBox(height: 28),
              const Text(
                'Supervision environnementale',
                style: TextStyle(color: _vertForet, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _BoutonModule(
                    icone: Icons.delete_outline,
                    libelle: 'Bacs à ordure',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AdminBacsScreen()),
                    ),
                  ),
                  _BoutonModule(
                    icone: Icons.map_outlined,
                    libelle: 'Zones',
                    onTap: () => _ouvrirModule(AppRoutes.zones),
                  ),
                  _BoutonModule(
                    icone: Icons.warning_amber_outlined,
                    libelle: 'Alertes',
                    onTap: () => _ouvrirModule(AppRoutes.alerts),
                  ),
                  _BoutonModule(
                    icone: Icons.analytics_outlined,
                    libelle: 'Analyses',
                    onTap: () => _ouvrirModule(AppRoutes.newAnalysis()),
                  ),
                  _BoutonModule(
                    icone: Icons.description_outlined,
                    libelle: 'Rapports',
                    onTap: () => _ouvrirModule(AppRoutes.reports),
                  ),
                ],
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

        Widget carte(IconData icone, String valeur, String libelle, {String? sousTitre}) {
          return SizedBox(
            width: largeurCarte,
            child: _CarteScore(icone: icone, valeur: valeur, libelle: libelle, sousTitre: sousTitre),
          );
        }

        return Wrap(
          spacing: espace,
          runSpacing: espace,
          children: [
            carte(
              Icons.people_alt_outlined,
              '${stats.comptesActifs}',
              'Comptes actifs',
              sousTitre: 'sur ${stats.totalComptes} comptes au total',
            ),
            carte(Icons.local_shipping_outlined, '${stats.agentsActifs}', 'Agents de terrain actifs'),
            carte(Icons.groups_2_outlined, '${stats.citoyensActifs}', 'Citoyens actifs'),
            carte(Icons.login, '${stats.connexionsAujourdHui}', "Connexions aujourd'hui"),
            carte(Icons.person_add_alt_1_outlined, '${stats.nouveauxInscrits7j}', 'Nouveaux inscrits (7 jours)'),
            carte(Icons.warning_amber_outlined, '${stats.alertesActives}', 'Alertes actives'),
            carte(Icons.check_circle_outline, '${stats.alertesTraitees}', 'Alertes traitées'),
          ],
        );
      },
    );
  }

  Widget _buildInfoModules() {
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
              "Les indicateurs de plaintes, de camions et d'alertes d'assainissement s'afficheront ici "
              "dès l'activation des modules signalements et collectes.",
              style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoutonModule extends StatelessWidget {
  final IconData icone;
  final String libelle;
  final VoidCallback onTap;

  const _BoutonModule({required this.icone, required this.libelle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icone, color: CleanCouleurs.vertEco, size: 20),
      label: Text(
        libelle,
        style: const TextStyle(color: _vertForet, fontWeight: FontWeight.bold),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: CleanCouleurs.vertEco),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}

class _CarteScore extends StatelessWidget {
  final IconData icone;
  final String valeur;
  final String libelle;
  final String? sousTitre;

  const _CarteScore({
    required this.icone,
    required this.valeur,
    required this.libelle,
    this.sousTitre,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CleanCouleurs.blancPur,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valeur,
                  style: const TextStyle(
                    color: _vertForet,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(libelle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                if (sousTitre != null) ...[
                  const SizedBox(height: 2),
                  Text(sousTitre!, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                ],
              ],
            ),
          ),
          Icon(icone, size: 36, color: CleanCouleurs.vertEco),
        ],
      ),
    );
  }
}
