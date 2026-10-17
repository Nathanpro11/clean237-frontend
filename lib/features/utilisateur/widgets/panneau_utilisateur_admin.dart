import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/features/utilisateur/controller/admin_controller.dart';
import 'package:clean237_frontend/features/utilisateur/models/utilisateur_model.dart';

const Color _vertForet = Color(0xFF14532D);

String libelleRoleAdmin(String role) {
  switch (role) {
    case 'admin':
      return 'Admin';
    case 'agent':
      return 'Agent';
    default:
      return 'Citoyen';
  }
}

/// Panneau latéral droit (RBAC) : activation du compte, rôle, permissions du rôle
/// (lecture seule : elles appartiennent au rôle, pas à l'utilisateur) et trace d'audit.
/// À ouvrir avec showGeneralDialog + SlideTransition.
class PanneauUtilisateurAdmin extends StatefulWidget {
  final UtilisateurModel utilisateur;

  const PanneauUtilisateurAdmin({super.key, required this.utilisateur});

  @override
  State<PanneauUtilisateurAdmin> createState() => _PanneauUtilisateurAdminState();
}

class _PanneauUtilisateurAdminState extends State<PanneauUtilisateurAdmin> {
  static const List<String> _rolesDisponibles = ['citoyen', 'agent', 'admin'];

  late bool _estActif;
  late String _roleNom;
  late Future<String> _futureIp;
  bool _enregistrement = false;

  @override
  void initState() {
    super.initState();
    final u = widget.utilisateur;
    _estActif = u.estActif;
    _roleNom = _rolesDisponibles.contains(u.roleNom) ? u.roleNom : 'citoyen';
    _futureIp = context.read<AdminController>().dernierIpAudite(u.id);
  }

  Future<void> _enregistrer() async {
    setState(() => _enregistrement = true);

    final admin = context.read<AdminController>();
    final messager = ScaffoldMessenger.of(context);
    final navigateur = Navigator.of(context);

    final succes = await admin.mettreAJourUtilisateur(
      id: widget.utilisateur.id,
      estActif: _estActif,
      roleNom: _roleNom,
    );

    navigateur.pop();
    messager.showSnackBar(
      SnackBar(
        content: Text(
          succes
              ? 'Droits de ${widget.utilisateur.nom} mis à jour.'
              : (admin.messageErreur ?? 'Échec de la mise à jour.'),
        ),
        backgroundColor: succes ? CleanCouleurs.vertEco : CleanCouleurs.rougeAlerte,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final largeurEcran = MediaQuery.of(context).size.width;
    final largeurPanneau = math.min(420.0, largeurEcran * 0.92);

    return Material(
      color: CleanCouleurs.blancPur,
      child: SizedBox(
        width: largeurPanneau,
        height: double.infinity,
        child: SafeArea(
          child: Column(
            children: [
              _buildEntete(),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasculeActif(),
                      const SizedBox(height: 24),
                      _buildTitre('Rôle du compte'),
                      const SizedBox(height: 8),
                      _buildSelecteurRole(),
                      const SizedBox(height: 24),
                      _buildTitre('Permissions du rôle actuel (lecture seule)'),
                      const SizedBox(height: 8),
                      _buildPermissionsLectureSeule(),
                      const SizedBox(height: 24),
                      _buildCarteTracabilite(),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _enregistrement ? null : _enregistrer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CleanCouleurs.vertEco,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  child: _enregistrement
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Enregistrer les modifications',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntete() {
    final u = widget.utilisateur;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: CleanCouleurs.vertEco,
            child: Text(
              u.nom.isNotEmpty ? u.nom[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  u.nom,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _vertForet, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  u.email,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTitre(String texte) {
    return Text(
      texte,
      style: const TextStyle(color: _vertForet, fontWeight: FontWeight.bold, fontSize: 13),
    );
  }

  Widget _buildBasculeActif() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _estActif ? CleanCouleurs.vertEco.withAlpha(20) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _estActif ? CleanCouleurs.vertEco : Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _estActif ? 'Compte actif' : 'Compte désactivé',
                  style: const TextStyle(color: _vertForet, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Suppression logique : estActif, historique conservé.',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: _estActif,
            activeTrackColor: CleanCouleurs.vertEco,
            activeColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade400,
            inactiveThumbColor: Colors.white,
            onChanged: (valeur) => setState(() => _estActif = valeur),
          ),
        ],
      ),
    );
  }

  Widget _buildSelecteurRole() {
    return DropdownButtonFormField<String>(
      value: _roleNom,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.badge_outlined, color: CleanCouleurs.vertEco, size: 20),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CleanCouleurs.vertEco, width: 1.5),
        ),
      ),
      items: _rolesDisponibles
          .map((r) => DropdownMenuItem(value: r, child: Text(libelleRoleAdmin(r))))
          .toList(),
      onChanged: (valeur) {
        if (valeur != null) setState(() => _roleNom = valeur);
      },
    );
  }

  Widget _buildPermissionsLectureSeule() {
    final permissions = widget.utilisateur.permissions;
    if (permissions.isEmpty) {
      return const Text('Aucune permission.', style: TextStyle(color: Colors.grey, fontSize: 12));
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: permissions
          .map(
            (p) => Chip(
              label: Text(p, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: _vertForet)),
              visualDensity: VisualDensity.compact,
              backgroundColor: CleanCouleurs.grisFond,
              side: BorderSide(color: Colors.grey.shade300),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCarteTracabilite() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2A1D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: FutureBuilder<String>(
        future: _futureIp,
        builder: (context, instantane) {
          final ip = instantane.data ?? '...';
          const style = TextStyle(fontFamily: 'monospace', fontSize: 12, color: Color(0xFF86EFAC), height: 1.5);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "TRACE D'AUDIT",
                style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.white54),
              ),
              const SizedBox(height: 6),
              Text('user_id: ${widget.utilisateur.id}', style: style),
              const Text('action: mutation_privileges', style: style),
              Text('Dernière IP auditée: $ip', style: style),
            ],
          );
        },
      ),
    );
  }
}