import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/features/utilisateur/controller/admin_controller.dart';
import 'package:clean237_frontend/features/utilisateur/controller/agent_controller.dart';
import 'package:clean237_frontend/features/utilisateur/controller/auth_controller.dart';
import 'package:clean237_frontend/features/utilisateur/controller/citoyen_controller.dart';
import 'package:clean237_frontend/features/utilisateur/controller/parametres_controller.dart';
import 'package:clean237_frontend/features/utilisateur/controller/profil_controller.dart';
import 'package:clean237_frontend/features/utilisateur/repository/admin_repository.dart';
import 'package:clean237_frontend/features/utilisateur/repository/agent_repository.dart';
import 'package:clean237_frontend/features/utilisateur/repository/auth_repository.dart';
import 'package:clean237_frontend/features/utilisateur/repository/citoyen_repository.dart';
import 'package:clean237_frontend/features/utilisateur/repository/api_admin_repository.dart';
import 'package:clean237_frontend/features/utilisateur/repository/api_agent_repository.dart';
import 'package:clean237_frontend/features/utilisateur/repository/api_auth_repository.dart';
import 'package:clean237_frontend/features/utilisateur/repository/api_citoyen_repository.dart';
import 'package:clean237_frontend/features/utilisateur/repository/fake_admin_repository.dart';
import 'package:clean237_frontend/features/utilisateur/repository/fake_agent_repository.dart';
import 'package:clean237_frontend/features/utilisateur/repository/fake_auth_repository.dart';
import 'package:clean237_frontend/features/utilisateur/repository/fake_citoyen_repository.dart';
import 'package:clean237_frontend/features/utilisateur/repository/prefs_parametres_repository.dart';
import 'package:clean237_frontend/features/utilisateur/repository/utilisateurs_store.dart';
import 'package:clean237_frontend/features/utilisateur/screen/splash_screen.dart';

/// Mode démo sans serveur : flutter run --dart-define=OFFLINE=true
const bool kModeHorsLigne = bool.fromEnvironment('OFFLINE');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AuthRepository authRepo;
  final AdminRepository adminRepo;
  final AgentRepository agentRepo;
  final CitoyenRepository citoyenRepo;

  if (kModeHorsLigne) {
    // Source unique des comptes simulés, partagée par Auth et Admin.
    final store = await UtilisateursStore.creer();
    authRepo = FakeAuthRepository(store);
    adminRepo = FakeAdminRepository(store);
    agentRepo = FakeAgentRepository();
    citoyenRepo = FakeCitoyenRepository();
  } else {
    // Backend Express : URL réglable via --dart-define=API_URL=http://<IP>:3000/api
    authRepo = ApiAuthRepository();
    adminRepo = ApiAdminRepository();
    agentRepo = ApiAgentRepository();
    citoyenRepo = ApiCitoyenRepository();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController(authRepo)),
        ChangeNotifierProvider(create: (_) => ProfilController()),
        ChangeNotifierProvider(create: (_) => AdminController(adminRepo)),
        ChangeNotifierProvider(create: (_) => AgentController(agentRepo)),
        ChangeNotifierProvider(create: (_) => CitoyenController(citoyenRepo)),
        ChangeNotifierProvider(create: (_) => ParametresController(SharedPrefsParametresRepository())),
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
      home: const SplashScreen(),
    );
  }
}