import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/features/utilisateur/controller/auth_controller.dart';
import 'package:clean237_frontend/features/utilisateur/screen/inscription_screen.dart';

class ConnexionScreen extends StatefulWidget {
  const ConnexionScreen({super.key});

  @override
  State<ConnexionScreen> createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends State<ConnexionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validerConnexion() async {
    if (_formKey.currentState!.validate()) {
      final authCtrl = context.read<AuthController>();
      final succes = await authCtrl.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (succes && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connexion validée !'), backgroundColor: CleanCouleurs.vertEco),
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
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/logo.png', width: 30, height: 30, errorBuilder: (c, e, s) => const Icon(Icons.eco, color: CleanCouleurs.vertEco)),
                      const SizedBox(width: 8),
                      const Text('Clean237', style: TextStyle(color: CleanCouleurs.anthracite, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 40),
                  if (authCtrl.messageErreur != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: CleanCouleurs.rougeAlerte.withOpacity(0.1),
                        border: Border.all(color: CleanCouleurs.rougeAlerte),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(authCtrl.messageErreur!, style: const TextStyle(color: CleanCouleurs.rougeAlerte, fontWeight: FontWeight.bold)),
                    ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined, color: CleanCouleurs.vertEco)),
                    validator: (v) => (v == null || !v.contains('@')) ? 'Email invalide' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Mot de passe', prefixIcon: Icon(Icons.lock_outline, color: CleanCouleurs.vertEco)),
                    validator: (v) => (v == null || v.length < 6) ? '6 caractères minimum' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: authCtrl.estEnCoursDeChargement ? null : _validerConnexion,
                    style: ElevatedButton.styleFrom(backgroundColor: CleanCouleurs.vertEco, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: authCtrl.estEnCoursDeChargement 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text('Se connecter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const InscriptionScreen())),
                    child: const Text('Créer un compte', style: TextStyle(color: CleanCouleurs.vertEco)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
