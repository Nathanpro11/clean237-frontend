import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/features/utilisateur/controller/auth_controller.dart';
import 'package:clean237_frontend/features/utilisateur/controller/profil_controller.dart';
import 'package:clean237_frontend/features/utilisateur/repository/fake_auth_repository.dart';
import 'package:clean237_frontend/features/utilisateur/screen/splash_screen.dart';

void main() {
  runApp(
    // 🎯 CRITÈRE GRILLE : Initialisation et couplage de l'architecture MVVM / Providers
    MultiProvider(
      providers: [
        // 🧪 MODE DÉVELOPPEMENT SANS BACKEND :
        // FakeAuthRepository() simule les réponses du serveur.
        // Quand le backend sera prêt, remplacer par : AuthController(ApiAuthRepository())
        ChangeNotifierProvider(create: (context) => AuthController(FakeAuthRepository())),
        ChangeNotifierProvider(create: (context) => ProfilController()),
      ],
      child: const Clean237App(),
    ),
  );
}

class Clean237App extends StatelessWidget {
  const Clean237App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clean237',
      debugShowCheckedModeBanner: false,

      // ✅ CHARTE GRAPHIQUE UNIFIÉE : Application globale du thème Vert & Blanc
      theme: ThemeData(
        scaffoldBackgroundColor: CleanCouleurs.grisFond,
        primaryColor: CleanCouleurs.vertEco,
        colorScheme: ColorScheme.fromSeed(
          seedColor: CleanCouleurs.vertEco,
          primary: CleanCouleurs.vertEco,
        ),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
      ),

      // 🎯 POINT D'ENTRÉE : Lancement sur le Splash Screen officiel pour tester le flux
      home: const SplashScreen(),
    );
  }
}