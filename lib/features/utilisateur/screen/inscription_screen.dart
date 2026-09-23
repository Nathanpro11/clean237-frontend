import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/features/utilisateur/controller/auth_controller.dart';

class InscriptionScreen extends StatefulWidget {
  const InscriptionScreen({super.key});

  @override
  State<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends State<InscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _matriculeController = TextEditingController();
  final _zoneController = TextEditingController();

  String _profilSelectionne = 'citoyen';
  bool _accepteConditions = false;
  bool _masquerMotDePasse = true;

  @override
  void dispose() {
    _nomController.dispose(); _emailController.dispose(); _telController.dispose();
    _passwordController.dispose(); _confirmPasswordController.dispose();
    _matriculeController.dispose(); _zoneController.dispose();
    super.dispose();
  }

  void _validerEtInscrire() async {
    if (!_accepteConditions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez accepter les Conditions d\'utilisation'), backgroundColor: CleanCouleurs.rougeAlerte),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final authCtrl = context.read<AuthController>();
      
      final succes = await authCtrl.inscrireUnUtilisateur(
        nom: _nomController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        telephone: _telController.text.trim(),
        motDepasse: _passwordController.text.trim(),
        profil: _profilSelectionne,
        matricule: _profilSelectionne == 'agent' ? _matriculeController.text.trim() : null,
        zoneAffectee: _profilSelectionne == 'agent' ? _zoneController.text.trim() : null,
      );

      if (succes && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte créé avec succès !'), backgroundColor: CleanCouleurs.vertEco),
        );
        Navigator.pop(context); // 🎯 LIEN DE NAVIGATION : Retour automatique au login
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: CleanCouleurs.blancPur,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CleanCouleurs.anthracite),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('S\'inscrire', style: TextStyle(color: CleanCouleurs.vertEco, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Inscription', style: TextStyle(color: CleanCouleurs.anthracite, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Rejoignez-nous pour un espace étincelant.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 30),

                  _buildLabel('Nom complet'),
                  TextFormField(controller: _nomController, decoration: _buildInputDecoration('Jean-Pierre Nguene', Icons.person_outline), validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null),
                  const SizedBox(height: 18),

                  _buildLabel('Adresse Email'),
                  TextFormField(controller: _emailController, decoration: _buildInputDecoration('exemple@domain.com', Icons.mail_outline), validator: (v) => (v == null || !v.contains('@')) ? 'Invalide' : null),
                  const SizedBox(height: 18),

                  _buildLabel('Numéro de Téléphone'),
                  TextFormField(controller: _telController, decoration: _buildInputDecoration('+237 6xx xx xx xx', Icons.phone_android_outlined), validator: (v) => (v == null || v.length < 9) ? 'Incomplet' : null),
                  const SizedBox(height: 18),

                  _buildLabel('Type de Profil'),
                  DropdownButtonFormField<String>(
                    value: _profilSelectionne,
                    decoration: _buildInputDecoration('', Icons.assignment_ind_outlined),
                    items: const [
                      DropdownMenuItem(value: 'citoyen', child: Text('Citoyen Standard')),
                      DropdownMenuItem(value: 'agent', child: Text('Agent de Collecte Terrain')),
                    ],
                    onChanged: (val) => setState(() => _profilSelectionne = val!),
                  ),
                  const SizedBox(height: 18),

                  // UX Interactive Profil Agent
                  if (_profilSelectionne == 'agent') ...[
                    _buildLabel('Matricule Professionnel'),
                    TextFormField(controller: _matriculeController, decoration: _buildInputDecoration('Ex: AGT-237-001', Icons.badge_outlined), validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null),
                    const SizedBox(height: 18),
                    _buildLabel('Zone d\'affectation'),
                    TextFormField(controller: _zoneController, decoration: _buildInputDecoration('Ex: Yaoundé VI', Icons.map_outlined), validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null),
                    const SizedBox(height: 18),
                  ],

                  _buildLabel('Mot de passe'),
                  TextFormField(controller: _passwordController, obscureText: _masquerMotDePasse, decoration: _buildInputDecoration('••••••••', Icons.lock_outline, avecSuffix: true), validator: (v) => (v == null || v.length < 6) ? '6 caractères min.' : null),
                  const SizedBox(height: 18),

                  _buildLabel('Confirmer le mot de passe'),
                  TextFormField(controller: _confirmPasswordController, obscureText: _masquerMotDePasse, decoration: _buildInputDecoration('••••••••', Icons.lock_clock_outlined), validator: (v) => (v != _passwordController.text) ? 'Mots de passe différents' : null),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Checkbox(value: _accepteConditions, activeColor: CleanCouleurs.vertEco, onChanged: (val) => setState(() => _accepteConditions = val!)),
                      const Text('J\'accepte les Conditions d\'utilisation', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 25),

                  ElevatedButton(
                    onPressed: authCtrl.estEnCoursDeChargement ? null : _validerEtInscrire,
                    style: ElevatedButton.styleFrom(backgroundColor: CleanCouleurs.vertEco, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), elevation: 0),
                    child: authCtrl.estEnCoursDeChargement
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('S\'inscrire', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String txt) => Padding(padding: const EdgeInsets.only(bottom: 6.0), child: Text(txt, style: const TextStyle(color: CleanCouleurs.anthracite, fontWeight: FontWeight.w600, fontSize: 14)));

  InputDecoration _buildInputDecoration(String hint, IconData prefix, {bool avecSuffix = false}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(prefix, color: CleanCouleurs.vertEco, size: 20),
      suffixIcon: avecSuffix ? IconButton(icon: Icon(_masquerMotDePasse ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey, size: 20), onPressed: () => setState(() => _masquerMotDePasse = !_masquerMotDePasse)) : null,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: CleanCouleurs.vertEco, width: 1.5)),
    );
  }
}
