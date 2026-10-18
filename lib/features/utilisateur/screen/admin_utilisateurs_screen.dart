import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/features/utilisateur/controller/admin_controller.dart';
import 'package:clean237_frontend/features/utilisateur/models/utilisateur_model.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/garde_acces.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/panneau_utilisateur_admin.dart';

const Color _vertForet = Color(0xFF14532D);

// Numéro mobile camerounais : préfixe +237/237 optionnel, puis 6 et 8 chiffres.
final RegExp _regexTelephone = RegExp(r'^(\+?237)?6\d{8}$');

/// Tableau des comptes du système + panneau latéral RBAC au clic sur une ligne.
class AdminUtilisateursScreen extends StatelessWidget {
  const AdminUtilisateursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GardeAcces(
      rolesAutorises: ['admin'],
      child: _AdminUtilisateursContenu(),
    );
  }
}

class _AdminUtilisateursContenu extends StatefulWidget {
  const _AdminUtilisateursContenu();

  @override
  State<_AdminUtilisateursContenu> createState() => _AdminUtilisateursContenuState();
}

class _AdminUtilisateursContenuState extends State<_AdminUtilisateursContenu> {
  String _filtreStatut = 'tous'; // tous / actifs / inactifs

  @override
  void initState() {
    super.initState();
    _chargerListe();
  }

  void _chargerListe() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AdminController>().chargerUtilisateurs();
    });
  }

  void _ouvrirPanneau(UtilisateurModel utilisateur) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fermer le panneau',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (contexteDialogue, animation, animationSecondaire) {
        return Align(
          alignment: Alignment.centerRight,
          child: PanneauUtilisateurAdmin(utilisateur: utilisateur),
        );
      },
      transitionBuilder: (contexteDialogue, animation, animationSecondaire, enfant) {
        final glissement = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return SlideTransition(position: glissement, child: enfant);
      },
    );
  }

  // ⚠️ Logique volontairement minimale ici (View) : construction du formulaire
  // + validation + gestion de l'état d'ouverture du dialogue (purement UI).
  // Le nettoyage/mapping des valeurs (téléphone, trim, matricule/zone selon
  // le rôle) vit dans AdminController.soumettreCreationCompte().
  void _ouvrirDialogueCreationCompte(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();
    String roleSelectionne = 'citoyen';
    bool masquerMotDePasse = true;
    bool enregistrement = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialogue) {
            return AlertDialog(
              title: const Text('Créer un compte'),
              content: SizedBox(
                width: 380,
                child: FormBuilder(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormBuilderTextField(
                          name: 'nom',
                          decoration: const InputDecoration(labelText: 'Nom complet'),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: 'Requis'),
                            FormBuilderValidators.minLength(2, errorText: 'Trop court'),
                          ]),
                        ),
                        const SizedBox(height: 12),
                        FormBuilderTextField(
                          name: 'email',
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: 'Requis'),
                            FormBuilderValidators.email(errorText: 'Email invalide'),
                          ]),
                        ),
                        const SizedBox(height: 12),
                        FormBuilderTextField(
                          name: 'telephone',
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(labelText: 'Téléphone', hintText: '+237 6xx xx xx xx'),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: 'Requis'),
                            (v) {
                              final nettoye = (v ?? '').replaceAll(RegExp(r'[\s-]'), '');
                              return _regexTelephone.hasMatch(nettoye) ? null : 'Numéro camerounais invalide';
                            },
                          ]),
                        ),
                        const SizedBox(height: 12),
                        FormBuilderDropdown<String>(
                          name: 'role',
                          initialValue: roleSelectionne,
                          decoration: const InputDecoration(labelText: 'Rôle'),
                          items: const [
                            DropdownMenuItem(value: 'citoyen', child: Text('Citoyen')),
                            DropdownMenuItem(value: 'agent', child: Text('Agent de Terrain')),
                            DropdownMenuItem(value: 'admin', child: Text('Admin')),
                          ],
                          onChanged: (val) => setStateDialogue(() => roleSelectionne = val ?? 'citoyen'),
                        ),
                        if (roleSelectionne == 'agent') ...[
                          const SizedBox(height: 12),
                          FormBuilderTextField(
                            name: 'matricule',
                            decoration: const InputDecoration(labelText: 'Matricule', hintText: 'AGT-237-001'),
                            validator: FormBuilderValidators.required(errorText: 'Requis'),
                          ),
                          const SizedBox(height: 12),
                          FormBuilderTextField(
                            name: 'zone',
                            decoration: const InputDecoration(labelText: 'Zone affectée', hintText: 'Yaoundé VI'),
                            validator: FormBuilderValidators.required(errorText: 'Requis'),
                          ),
                        ],
                        const SizedBox(height: 12),
                        FormBuilderTextField(
                          name: 'motDepasse',
                          obscureText: masquerMotDePasse,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            suffixIcon: IconButton(
                              icon: Icon(masquerMotDePasse ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                              onPressed: () => setStateDialogue(() => masquerMotDePasse = !masquerMotDePasse),
                            ),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: 'Requis'),
                            FormBuilderValidators.minLength(6, errorText: '6 caractères min.'),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: enregistrement ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: CleanCouleurs.vertEco),
                  onPressed: enregistrement
                      ? null
                      : () async {
                          final estValide = formKey.currentState?.saveAndValidate() ?? false;
                          if (!estValide) return;

                          setStateDialogue(() => enregistrement = true);

                          final valeurs = formKey.currentState!.value;
                          final admin = context.read<AdminController>();

                          final succes = await admin.soumettreCreationCompte(valeurs, roleSelectionne);

                          if (dialogContext.mounted) Navigator.pop(dialogContext);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(succes ? 'Compte créé avec succès !' : (admin.messageErreur ?? 'Échec de la création.')),
                                backgroundColor: succes ? CleanCouleurs.vertEco : CleanCouleurs.rougeAlerte,
                              ),
                            );
                          }
                        },
                  child: enregistrement
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Créer', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();
    final tous = admin.utilisateurs;
    final utilisateurs = switch (_filtreStatut) {
      'actifs' => tous.where((u) => u.estActif).toList(),
      'inactifs' => tous.where((u) => !u.estActif).toList(),
      _ => tous,
    };

    return Scaffold(
      backgroundColor: CleanCouleurs.grisFond,
      appBar: AppBar(
        backgroundColor: CleanCouleurs.blancPur,
        elevation: 0,
        iconTheme: const IconThemeData(color: _vertForet),
        title: const Text(
          'Comptes et accès',
          style: TextStyle(color: _vertForet, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Créer un compte',
            icon: const Icon(Icons.person_add_alt_1_outlined, color: CleanCouleurs.vertEco),
            onPressed: () => _ouvrirDialogueCreationCompte(context),
          ),
        ],
      ),
      body: tous.isEmpty
          ? Center(
              child: admin.enChargement
                  ? const CircularProgressIndicator(color: CleanCouleurs.vertEco)
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.wifi_off_outlined, size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(admin.messageErreur ?? 'Aucun compte.', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        if (admin.messageErreur != null)
                          OutlinedButton.icon(
                            onPressed: _chargerListe,
                            icon: const Icon(Icons.refresh, color: CleanCouleurs.vertEco, size: 18),
                            label: const Text('Réessayer', style: TextStyle(color: CleanCouleurs.vertEco)),
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: CleanCouleurs.vertEco)),
                          ),
                      ],
                    ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Touchez une ligne pour modifier le rôle, le statut et les permissions.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 12),
                _buildFiltres(),
                const SizedBox(height: 12),
                if (utilisateurs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('Aucun compte pour ce filtre.', style: TextStyle(color: Colors.grey))),
                  )
                else
                  _buildTableau(utilisateurs),
              ],
            ),
    );
  }

  Widget _buildFiltres() {
    Widget bouton(String valeur, String libelle) {
      return ChoiceChip(
        label: Text(libelle),
        selected: _filtreStatut == valeur,
        selectedColor: CleanCouleurs.vertEco.withAlpha(40),
        onSelected: (_) => setState(() => _filtreStatut = valeur),
      );
    }

    return Wrap(
      spacing: 8,
      children: [
        bouton('tous', 'Tous'),
        bouton('actifs', 'Actifs'),
        bouton('inactifs', 'Inactifs'),
      ],
    );
  }

  Widget _buildTableau(List<UtilisateurModel> utilisateurs) {
    final largeurMin = MediaQuery.of(context).size.width - 32;

    return Container(
      decoration: BoxDecoration(
        color: CleanCouleurs.blancPur,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: largeurMin),
            child: DataTable(
              showCheckboxColumn: false,
              columnSpacing: 24,
              headingRowColor: WidgetStateProperty.all(CleanCouleurs.grisFond),
              headingTextStyle: const TextStyle(
                color: _vertForet,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              columns: const [
                DataColumn(label: Text('Nom')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Rôle')),
                DataColumn(label: Text('Statut')),
                DataColumn(label: Text('Actions')),
              ],
              rows: utilisateurs.map(_construireLigne).toList(),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _construireLigne(UtilisateurModel u) {
    return DataRow(
      onSelectChanged: (_) => _ouvrirPanneau(u),
      cells: [
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: CleanCouleurs.vertEco,
                child: Text(
                  u.nom.isNotEmpty ? u.nom[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Text(u.nom, style: const TextStyle(color: _vertForet, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
        DataCell(Text(u.email, style: const TextStyle(fontSize: 12, color: Colors.grey))),
        DataCell(_buildPuceRole(u.roleNom)),
        DataCell(_buildPuceStatut(u.estActif)),
        DataCell(
          IconButton(
            tooltip: 'Modifier les droits',
            icon: const Icon(Icons.tune, color: CleanCouleurs.vertEco, size: 20),
            onPressed: () => _ouvrirPanneau(u),
          ),
        ),
      ],
    );
  }

  Widget _buildPuceRole(String role) {
    final estAdmin = role == 'admin';
    final couleur = estAdmin ? const Color(0xFFDC143C) : _vertForet;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: couleur.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        libelleRoleAdmin(role),
        style: TextStyle(color: couleur, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPuceStatut(bool estActif) {
    final couleur = estActif ? CleanCouleurs.vertEco : Colors.grey;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: couleur, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          estActif ? 'Actif' : 'Désactivé',
          style: TextStyle(color: couleur, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}