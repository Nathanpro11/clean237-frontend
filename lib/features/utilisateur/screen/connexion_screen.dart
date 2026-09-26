import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/features/utilisateur/controller/auth_controller.dart';
import 'package:clean237_frontend/features/utilisateur/screen/inscription_screen.dart';
import 'package:clean237_frontend/features/utilisateur/screen/accueil_screen.dart';
import 'package:clean237_frontend/features/utilisateur/screen/dashboard_screen.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/auth_toggle_tabs.dart';

class ConnexionScreen extends StatefulWidget {
  const ConnexionScreen({super.key});

  @override
  State<ConnexionScreen> createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends State<ConnexionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _masquerMotDePasse = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _soumettreFormulaire() async {
    if (_formKey.currentState!.validate()) {
      final authCtrl = context.read<AuthController>();
      final succes = await authCtrl.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (succes && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentification réussie !'),
            backgroundColor: CleanCouleurs.vertEco,
          ),
        );
        // 🎯 Navigation selon le rôle : citoyen -> Accueil, admin/agent -> Dashboard
        final role = authCtrl.utilisateur?.roleNom ?? 'citoyen';
        final ecranDestination = role == 'citoyen'
            ? const AccueilScreen()
            : const DashboardScreen();

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ecranDestination),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: CleanCouleurs.blancPur,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.06,
              vertical: 16.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            'assets/logo.jpeg',
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Clean237',
                          style: TextStyle(
                            color: CleanCouleurs.anthracite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const AuthToggleTabs(estConnexionActive: true),
                    const SizedBox(height: 32),
                    const Text(
                      'Connexion',
                      style: TextStyle(
                        color: CleanCouleurs.anthracite,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Heureux de vous revoir ! Connectez-vous.',
                      style: TextStyle(color: Color(0xFF7F8C8D), fontSize: 14),
                    ),
                    const SizedBox(height: 40),
                    if (authCtrl.messageErreur != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: CleanCouleurs.rougeAlerte.withOpacity(0.08),
                          border: Border.all(
                            color: CleanCouleurs.rougeAlerte,
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          authCtrl.messageErreur!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: CleanCouleurs.rougeAlerte,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    const Text(
                      'Adresse Email',
                      style: TextStyle(
                        color: CleanCouleurs.anthracite,
                        fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    enabled: !authCtrl.estBloqueAntiBruteforce,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CleanCouleurs.anthracite,
                    ),
                    decoration: _buildInputDecoration(
                      hint: 'exemple@domain.com',
                      prefixIcon: Icons.mail_outline,
                    ),
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Adresse e-mail invalide'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Mot de passe',
                    style: TextStyle(
                      color: CleanCouleurs.anthracite,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    enabled: !authCtrl.estBloqueAntiBruteforce,
                    obscureText: _masquerMotDePasse,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CleanCouleurs.anthracite,
                    ),
                    decoration: _buildInputDecoration(
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      suffix: IconButton(
                        icon: Icon(
                          _masquerMotDePasse
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _masquerMotDePasse = !_masquerMotDePasse,
                        ),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Mot de passe trop court (6 caract. min)'
                        : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text(
                        'Mot de passe oublié ?',
                        style: TextStyle(
                          color: CleanCouleurs.vertEco,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        (authCtrl.estEnCoursDeChargement ||
                            authCtrl.estBloqueAntiBruteforce)
                        ? null
                        : _soumettreFormulaire,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CleanCouleurs.vertEco,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: authCtrl.estEnCoursDeChargement
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Se connecter',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 35),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade200,
                          thickness: 1,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'ou continuer avec',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade200,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBoutonSocial(
                          'Google',
                          const FaIcon(FontAwesomeIcons.google, color: Colors.redAccent, size: 18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildBoutonSocial(
                          'Apple',
                          const Icon(Icons.apple, color: CleanCouleurs.anthracite, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Nouveau ? ',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const InscriptionScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Créer un compte',
                          style: TextStyle(
                            color: CleanCouleurs.vertEco,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: CleanCouleurs.vertEco, size: 18),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: CleanCouleurs.vertEco, width: 1.5),
      ),
    );
  }

  Widget _buildBoutonSocial(String label, Widget icone) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icone,
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: CleanCouleurs.anthracite,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}