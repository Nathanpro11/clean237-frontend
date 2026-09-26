import 'package:flutter/material.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/features/utilisateur/screen/connexion_screen.dart';
import 'package:clean237_frontend/features/utilisateur/screen/inscription_screen.dart';

/// Bascule "Se connecter / S'inscrire", inspirée de la maquette
/// mais avec les couleurs Clean237 (vert éco au lieu du violet).
class AuthToggleTabs extends StatelessWidget {
  final bool estConnexionActive;

  const AuthToggleTabs({super.key, required this.estConnexionActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CleanCouleurs.grisFond,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(child: _buildOnglet(context, 'Se connecter', estActif: estConnexionActive)),
          Expanded(child: _buildOnglet(context, "S'inscrire", estActif: !estConnexionActive)),
        ],
      ),
    );
  }

  Widget _buildOnglet(BuildContext context, String label, {required bool estActif}) {
    return GestureDetector(
      onTap: () {
        if (estActif) return; // déjà sur cet écran
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => label == 'Se connecter' ? const ConnexionScreen() : const InscriptionScreen(),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: estActif ? CleanCouleurs.vertEco : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: estActif ? Colors.white : Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}