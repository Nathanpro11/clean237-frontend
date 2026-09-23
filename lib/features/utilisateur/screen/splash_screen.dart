import 'package:flutter/material.dart';
import '../../../utils/constances/constances.dart';
import 'connexion_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialiserSessionEtNaviguer();
  }

  // 🎯 EXPÉRIENCE UTILISATEUR & NAVIGATION : Initialisation et redirection fluide (3 secondes)
  void _initialiserSessionEtNaviguer() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // Redirection définitive (pushReplacement) vers l'écran de connexion
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const ConnexionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // ✅ DESIGN GRAPHIQUE FIDÈLE : Dégradé Vert Éco officiel de l'équipe
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CleanCouleurs.vertEco,
              CleanCouleurs.vertHover, // Nuance plus sombre pour le contraste bas
            ],
          ),
        ),
        child: Stack(
          children: [
            // ✨ CERCLES DÉCORATIFS TRANSPARENTS (Fidèles à la maquette)
            Positioned(top: 140, left: -40, child: _buildCercleDecoratif(150)),
            Positioned(top: 280, right: -70, child: _buildCercleDecoratif(200)),
            Positioned(bottom: 200, left: -30, child: _buildCercleDecoratif(180)),
            Positioned(bottom: 80, right: 50, child: _buildCercleDecoratif(110)),

            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // 1. Nom de l'application (Blanc pur)
                    const Text(
                      'Clean237',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 2. Slogan arrondi encapsulé
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'Votre propreté, notre priorité',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 45),

                    // 3. ✅ CONTENEUR DU LOGO (Affiche l'image de votre dossier assets)
                    Container(
                      width: 135,
                      height: 135,
                      padding: const EdgeInsets.all(20), // Marges intérieures pour aérer le logo
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/logo.jpeg',
                          fit: BoxFit.contain,
                          // Sécurité : Si l'image rencontre un problème d'indexation, l'icône verte prend le relais
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.delete_outline, 
                              color: CleanCouleurs.vertEco, 
                              size: 65,
                            );
                          },
                        ),
                      ),
                    ),

                    const Spacer(),

                    // 4. Indicateur de progression (Les 3 points d'avancement)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPointIndicateur(true),
                        _buildPointIndicateur(false),
                        _buildPointIndicateur(false),
                      ],
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Constructeur des cercles d'ambiance transparents
  Widget _buildCercleDecoratif(double taille) {
    return Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.05),
      ),
    );
  }

  // Constructeur des points indicateurs du bas de page
  Widget _buildPointIndicateur(bool estActif) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: estActif ? 9 : 6,
      height: estActif ? 9 : 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: estActif ? Colors.white : Colors.white.withOpacity(0.35),
      ),
    );
  }
}
