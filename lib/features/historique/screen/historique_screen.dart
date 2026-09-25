import 'package:flutter/material.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/features/utilisateur/models/log_model.dart';
import 'package:clean237_frontend/shared/widgets/clean_bottom_nav.dart';

/// Écran "Historique d'activité", basé sur la maquette historique-audit.
/// Utilise LogModel. Données FACTICES en attendant un vrai HistoriqueRepository.
class HistoriqueScreen extends StatelessWidget {
  const HistoriqueScreen({super.key});

  // 🧪 Logs mockés — à remplacer par HistoriqueRepository plus tard
  List<LogModel> get _logsMock => [
        LogModel(
          id: '1',
          utilisateurId: 'u1',
          action: 'CONNEXION',
          description: "Connexion réussie à la session d'administration pour Néhémi Mbainadji.",
          ipAddress: '192.168.43.12',
          createdAt: DateTime(2026, 8, 23, 9, 30, 0),
        ),
        LogModel(
          id: '2',
          utilisateurId: 'u1',
          action: 'INSCRIPTION',
          description: 'Inscription initiale du compte citoyen pour le suivi de fidélité écologique.',
          ipAddress: '192.168.43.12',
          createdAt: DateTime(2026, 8, 23, 4, 11, 0),
        ),
        LogModel(
          id: '3',
          utilisateurId: 'u2',
          action: 'MODIFICATION_PROFIL',
          description: "Modification de l'adresse de collecte principale et du numéro de téléphone.",
          ipAddress: '127.0.0.1',
          createdAt: DateTime(2026, 7, 15, 14, 3, 0),
        ),
        LogModel(
          id: '4',
          utilisateurId: 'u3',
          action: 'CONNEXION',
          description: "Connexion réussie via le portail agent de terrain - Validation d'identité.",
          ipAddress: '192.168.1.50',
          createdAt: DateTime(2026, 3, 1, 8, 30, 0),
        ),
        LogModel(
          id: '5',
          utilisateurId: 'u3',
          action: 'INSCRIPTION',
          description: 'Enregistrement de la nouvelle benne intelligente connectée pour le secteur Yaoundé VI.',
          ipAddress: '10.0.0.4',
          createdAt: DateTime(2026, 3, 1, 8, 0, 0),
        ),
      ];

  Color _couleurPourAction(String action) {
    switch (action) {
      case 'CONNEXION':
        return Colors.blue;
      case 'INSCRIPTION':
        return CleanCouleurs.vertEco;
      case 'MODIFICATION_PROFIL':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formaterAction(String action) {
    return action.replaceAll('_', ' ').toLowerCase();
  }

  String _formaterDate(DateTime date) {
    const mois = [
      'Jan', 'Fev', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Aout', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final heure = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${mois[date.month - 1]} ${date.year}, $heure:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CleanCouleurs.anthracite,
      appBar: AppBar(
        backgroundColor: CleanCouleurs.anthracite,
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
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: _logsMock.length,
        itemBuilder: (context, index) {
          final log = _logsMock[index];
          final couleur = _couleurPourAction(log.action);
          final estDernier = index == _logsMock.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ligne verticale + point de la timeline
                Column(
                  children: [
                    Icon(Icons.circle, color: couleur, size: 14),
                    if (!estDernier)
                      Expanded(
                        child: Container(width: 2, color: Colors.grey.shade800),
                      ),
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
                          style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
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