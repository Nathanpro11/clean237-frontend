import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/features/utilisateur/controller/profil_controller.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/clean_bottom_nav.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/garde_acces.dart';

/// Écran "Historique d'activité" : journal d'audit réel de l'utilisateur
/// connecté (GET /utilisateurs/historique/:id), tiré pour actualiser.
class HistoriqueScreen extends StatelessWidget {
  const HistoriqueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GardeAcces(child: _HistoriqueContenu());
  }
}

class _HistoriqueContenu extends StatefulWidget {
  const _HistoriqueContenu();

  @override
  State<_HistoriqueContenu> createState() => _HistoriqueContenuState();
}

class _HistoriqueContenuState extends State<_HistoriqueContenu> {
  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    // Différé après le premier build (notifyListeners pendant le build est interdit).
    await Future<void>.delayed(Duration.zero);
    if (mounted) await context.read<ProfilController>().chargerHistorique();
  }

  Color _couleurPourAction(String action) {
    switch (action) {
      case 'CONNEXION':
        return Colors.blue;
      case 'INSCRIPTION':
        return CleanCouleurs.vertEco;
      case 'MODIFICATION_PROFIL':
        return Colors.orange;
      case 'CHANGEMENT_MOT_DE_PASSE':
        return Colors.purple;
      case 'DEMANDE_REINITIALISATION':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formaterAction(String action) => action.replaceAll('_', ' ').toLowerCase();

  String _formaterDate(DateTime utc) {
    final date = utc.toLocal(); // le serveur renvoie de l'UTC
    const mois = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    final heure = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${mois[date.month - 1]} ${date.year}, $heure:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ProfilController>();

    return Scaffold(
      backgroundColor: CleanCouleurs.grisFond,
      appBar: AppBar(
        backgroundColor: CleanCouleurs.vertEco,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          "Historique d'activité",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const CleanBottomNav(currentIndex: 3),
      body: _buildCorps(ctrl),
    );
  }

  Widget _buildCorps(ProfilController ctrl) {
    final logs = ctrl.historiqueLogs;

    if (logs.isEmpty) {
      return Center(
        child: ctrl.enChargement
            ? const CircularProgressIndicator(color: CleanCouleurs.vertEco)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    ctrl.messageErreur ?? 'Aucune activité enregistrée.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _charger,
                    icon: const Icon(Icons.refresh, color: CleanCouleurs.vertEco, size: 18),
                    label: const Text('Actualiser', style: TextStyle(color: CleanCouleurs.vertEco)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: CleanCouleurs.vertEco)),
                  ),
                ],
              ),
      );
    }

    return RefreshIndicator(
      color: CleanCouleurs.vertEco,
      onRefresh: () => context.read<ProfilController>().chargerHistorique(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          final couleur = _couleurPourAction(log.action);
          final estDernier = index == logs.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ligne verticale + point de la timeline
                Column(
                  children: [
                    Icon(Icons.circle, color: couleur, size: 14),
                    if (!estDernier)
                      Expanded(child: Container(width: 2, color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: couleur.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _formaterAction(log.action),
                            style: TextStyle(color: couleur, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          log.description,
                          style: const TextStyle(color: Colors.black, fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.wifi_tethering, color: Colors.grey.shade500, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              'IP: ${log.ipAddress}',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                            ),
                            const Spacer(),
                            Text(
                              _formaterDate(log.createdAt),
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}