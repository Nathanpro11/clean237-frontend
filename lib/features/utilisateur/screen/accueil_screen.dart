import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/features/utilisateur/controller/auth_controller.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/clean_bottom_nav.dart';

/// Écran d'accueil (vue Citoyen), basé sur la maquette "ecran-accueil".
/// Les missions du jour sont pour l'instant des données FACTICES (mock),
/// en attendant un vrai MissionRepository / backend.
class AccueilScreen extends StatelessWidget {
  const AccueilScreen({super.key});

  // 🧪 Données mockées le temps de brancher un vrai MissionRepository
  static const List<_MissionDuJour> _missionsMock = [
    _MissionDuJour(
      titre: 'Collecte quartier Yaoundé VI',
      heureEtLieu: '08:30 • Secteur 4',
      statut: 'À faire',
      couleurStatut: Colors.orange,
      detail: '1.2 km du point de départ',
      icone: Icons.location_on_outlined,
    ),
    _MissionDuJour(
      titre: 'Ramassage déchets biomédicaux',
      heureEtLieu: '11:00 • Centre de santé',
      statut: 'En cours',
      couleurStatut: Colors.blue,
      detail: '2 conteneurs à vérifier',
      icone: Icons.inventory_2_outlined,
    ),
    _MissionDuJour(
      titre: 'Nettoyage place publique',
      heureEtLieu: '14:30 • Marché central',
      statut: 'Terminé',
      couleurStatut: CleanCouleurs.vertEco,
      detail: 'Rapport envoyé avec succès',
      icone: Icons.check_circle_outline,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authCtrl = context.watch<AuthController>();
    final nom = authCtrl.utilisateur?.nom.split(' ').first ?? 'Utilisateur';

    return Scaffold(
      backgroundColor: CleanCouleurs.grisFond,
      body: SafeArea(
        child: Column(
          children: [
            _buildEnTete(nom),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildActionsRapides(nom),
                    const SizedBox(height: 24),
                    const Text(
                      'MISSIONS DU JOUR',
                      style: TextStyle(
                        color: CleanCouleurs.vertEco,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._missionsMock.map((m) => _buildCarteMission(m)),
                    const SizedBox(height: 20),
                    _buildFideliteEcologique(),
                    const SizedBox(height: 24),
                  ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: CleanCouleurs.blancPur,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: CleanCouleurs.vertEco,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.eco, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              const Text(
                'Clean237',
                style: TextStyle(
                  color: CleanCouleurs.anthracite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
            Expanded(child: _buildBoutonAction(Icons.add_box_outlined, 'Signaler un dépôt')),
            const SizedBox(width: 10),
            Expanded(child: _buildBoutonAction(Icons.local_shipping_outlined, 'Mes collectes')),
            const SizedBox(width: 10),
            Expanded(child: _buildBoutonAction(Icons.star_outline, 'Fidélité écologique')),
          ],
        ),
      ],
    );
  }

  Widget _buildBoutonAction(IconData icone, String label) {
    return Container(
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
    );
  }

  Widget _buildCarteMission(_MissionDuJour mission) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  mission.titre,
                  style: const TextStyle(color: CleanCouleurs.anthracite, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: mission.couleurStatut.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  mission.statut,
                  style: TextStyle(color: mission.couleurStatut, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            mission.heureEtLieu,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(mission.icone, color: CleanCouleurs.vertEco, size: 14),
              const SizedBox(width: 6),
              Text(
                mission.detail,
                style: const TextStyle(color: CleanCouleurs.anthracite, fontSize: 12),
              ),
            ],
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
            children: [
              const Text(
                'Fidélité écologique',
                style: TextStyle(color: CleanCouleurs.anthracite, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Text(
                '150 Points',
                style: TextStyle(color: CleanCouleurs.vertEco, fontWeight: FontWeight.bold, fontSize: 14),
              ),
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
        ],
      ),
    );
  }
}

class _MissionDuJour {
  final String titre;
  final String heureEtLieu;
  final String statut;
  final Color couleurStatut;
  final String detail;
  final IconData icone;

  const _MissionDuJour({
    required this.titre,
    required this.heureEtLieu,
    required this.statut,
    required this.couleurStatut,
    required this.detail,
    required this.icone,
  });
}