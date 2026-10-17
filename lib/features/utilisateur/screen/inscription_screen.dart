import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/features/utilisateur/controller/auth_controller.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/auth_toggle_tabs.dart';
import 'package:clean237_frontend/features/utilisateur/screen/connexion_screen.dart';

/// Inscription PUBLIQUE : crée un compte citoyen.
/// Les comptes agent / admin sont créés par un administrateur
/// (Gestion des comptes > Créer un compte).
class InscriptionScreen extends StatefulWidget {
  const InscriptionScreen({super.key});

  @override
  State<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends State<InscriptionScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _masquerMotDePasse = true;

  // Numéro mobile camerounais : préfixe +237/237 optionnel, puis 6 et 8 chiffres.
  static final RegExp _regexTelephone = RegExp(r'^(\+?237)?6\d{8}$');

  void _validerEtInscrire() async {
    final estValide = _formKey.currentState?.saveAndValidate() ?? false;
    if (!estValide) return;

    final valeurs = _formKey.currentState!.value;

    if (valeurs['conditions'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez accepter les Conditions d'utilisation"),
          backgroundColor: CleanCouleurs.rougeAlerte,
        ),
      );
      return;
    }

    final authCtrl = context.read<AuthController>();
    final telephoneNettoye = (valeurs['telephone'] as String).replaceAll(RegExp(r'[\s-]'), '');

    final succes = await authCtrl.inscrireUnUtilisateur(
      nom: (valeurs['nom'] as String).trim(),
      email: (valeurs['email'] as String).trim().toLowerCase(),
      telephone: telephoneNettoye,
      motDepasse: valeurs['motDepasse'] as String,
      profil: 'citoyen',
    );

    if (succes && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte créé avec succès !'), backgroundColor: CleanCouleurs.vertEco),
      );
      // Les onglets Connexion/Inscription utilisent pushReplacement : cet écran est
      // seul dans la pile, on revient explicitement vers la connexion.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ConnexionScreen()),
      );
    } else if (mounted && authCtrl.messageErreur != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authCtrl.messageErreur!), backgroundColor: CleanCouleurs.rougeAlerte),
      );
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
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.06,
              vertical: 16.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.arrow_back, color: CleanCouleurs.anthracite),
                          onPressed: () => Navigator.maybePop(context),
                        ),
                        const SizedBox(width: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset('assets/logo.jpeg', width: 24, height: 24, fit: BoxFit.cover),
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
                    const SizedBox(height: 24),
                    const AuthToggleTabs(estConnexionActive: false),
                    const SizedBox(height: 24),
                    const Text(
                      'Inscription',
                      style: TextStyle(color: CleanCouleurs.anthracite, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Rejoignez-nous pour un espace étincelant.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 30),

                    _buildLabel('Nom complet'),
                    FormBuilderTextField(
                      name: 'nom',
                      decoration: _buildInputDecoration('Jean-Pierre Nguene', Icons.person_outline),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'Requis'),
                        FormBuilderValidators.minLength(2, errorText: 'Trop court'),
                      ]),
                    ),
                    const SizedBox(height: 18),

                    _buildLabel('Adresse Email'),
                    FormBuilderTextField(
                      name: 'email',
                      keyboardType: TextInputType.emailAddress,
                      decoration: _buildInputDecoration('exemple@domain.com', Icons.mail_outline),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'Requis'),
                        FormBuilderValidators.email(errorText: 'Adresse email invalide'),
                      ]),
                    ),
                    const SizedBox(height: 18),

                    _buildLabel('Numéro de Téléphone'),
                    FormBuilderTextField(
                      name: 'telephone',
                      keyboardType: TextInputType.phone,
                      decoration: _buildInputDecoration('+237 6xx xx xx xx', Icons.phone_android_outlined),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'Requis'),
                        (v) {
                          final nettoye = (v ?? '').replaceAll(RegExp(r'[\s-]'), '');
                          return _regexTelephone.hasMatch(nettoye)
                              ? null
                              : 'Numéro camerounais invalide (ex: 6XX XX XX XX)';
                        },
                      ]),
                    ),
                    const SizedBox(height: 18),

                    _buildLabel('Mot de passe'),
                    FormBuilderTextField(
                      name: 'motDepasse',
                      obscureText: _masquerMotDePasse,
                      decoration: _buildInputDecoration('••••••••', Icons.lock_outline, avecSuffix: true),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'Requis'),
                        FormBuilderValidators.minLength(6, errorText: '6 caractères min.'),
                      ]),
                    ),
                    const SizedBox(height: 18),

                    _buildLabel('Confirmer le mot de passe'),
                    FormBuilderTextField(
                      name: 'confirmationMotDepasse',
                      obscureText: _masquerMotDePasse,
                      decoration: _buildInputDecoration('••••••••', Icons.lock_clock_outlined),
                      validator: (v) {
                        final motDepasse = _formKey.currentState?.fields['motDepasse']?.value as String?;
                        return (v != motDepasse) ? 'Mots de passe différents' : null;
                      },
                    ),
                    const SizedBox(height: 20),

                    FormBuilderCheckbox(
                      name: 'conditions',
                      initialValue: false,
                      activeColor: CleanCouleurs.vertEco,
                      title: const Text(
                        "J'accepte les Conditions d'utilisation",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 25),

                    ElevatedButton(
                      onPressed: authCtrl.estEnCoursDeChargement ? null : _validerEtInscrire,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CleanCouleurs.vertEco,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      child: authCtrl.estEnCoursDeChargement
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              "S'inscrire",
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String txt) => Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Text(
          txt,
          style: const TextStyle(color: CleanCouleurs.anthracite, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      );

  InputDecoration _buildInputDecoration(String hint, IconData prefix, {bool avecSuffix = false}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(prefix, color: CleanCouleurs.vertEco, size: 20),
      suffixIcon: avecSuffix
          ? IconButton(
              icon: Icon(
                _masquerMotDePasse ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: () => setState(() => _masquerMotDePasse = !_masquerMotDePasse),
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: CleanCouleurs.vertEco, width: 1.5),
      ),
    );
  }
}