import 'package:flutter/material.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';
import 'package:clean237_frontend/features/utilisateur/widgets/garde_acces.dart';

/// Écran Aide & Support (module Utilisateur).
/// FAQ dépliable + moyens de contact + formulaire de message.
class AideSupportScreen extends StatelessWidget {
  const AideSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GardeAcces(child: _AideSupportContenu());
  }
}

class _AideSupportContenu extends StatelessWidget {
  const _AideSupportContenu();

  static const List<Map<String, String>> _faqMock = [
    {
      'question': 'Comment signaler un dépôt sauvage ?',
      'reponse': 'Depuis l\'écran d\'accueil, appuyez sur "Signaler un dépôt", prenez une photo et validez la localisation.',
    },
    {
      'question': 'Comment gagner des points de fidélité écologique ?',
      'reponse': 'Chaque signalement validé et chaque collecte confirmée vous rapportent des points, visibles sur votre écran d\'accueil.',
    },
    {
      'question': 'Que faire si ma zone n\'est pas encore couverte ?',
      'reponse': 'Contactez le support via le formulaire ci-dessous, nous étendons progressivement la couverture des secteurs.',
    },
    {
      'question': 'Comment devenir Agent de Collecte Terrain ?',
      'reponse': 'Inscrivez-vous en sélectionnant "Agent de Collecte Terrain" lors de la création de compte, avec votre matricule professionnel.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CleanCouleurs.grisFond,
      appBar: AppBar(
        backgroundColor: CleanCouleurs.blancPur,
        elevation: 0,
        iconTheme: const IconThemeData(color: CleanCouleurs.anthracite),
        title: const Text(
          'Aide & Support',
          style: TextStyle(color: CleanCouleurs.anthracite, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Questions fréquentes',
            style: TextStyle(color: CleanCouleurs.anthracite, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: CleanCouleurs.blancPur,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: Material(
                type: MaterialType.transparency,
                borderRadius: BorderRadius.circular(14),
                clipBehavior: Clip.antiAlias,
                child: Column(
                children: _faqMock
                    .map((item) => ExpansionTile(
                          title: Text(
                            item['question']!,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: CleanCouleurs.anthracite),
                          ),
                          iconColor: CleanCouleurs.vertEco,
                          collapsedIconColor: Colors.grey,
                          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['reponse']!,
                              style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                            ),
                          ],
                        ))
                    .toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nous contacter',
            style: TextStyle(color: CleanCouleurs.anthracite, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: CleanCouleurs.blancPur,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Material(
              type: MaterialType.transparency,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.mail_outline, color: CleanCouleurs.vertEco),
                    title: const Text('support@clean237.cm', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Réponse sous 24h', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone_outlined, color: CleanCouleurs.vertEco),
                    title: const Text('+237 6XX XX XX XX', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Lun-Ven, 8h-17h', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _ouvrirFormulaireMessage(context),
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
            label: const Text('Envoyer un message', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: CleanCouleurs.vertEco,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
              minimumSize: const Size(double.infinity, 0),
            ),
          ),
        ],
      ),
    );
  }

  void _ouvrirFormulaireMessage(BuildContext context) {
    final messageController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Envoyer un message'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Décrivez votre problème ou votre question...',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Message requis' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: CleanCouleurs.vertEco),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Message envoyé ! Nous vous répondrons sous 24h.'),
                      backgroundColor: CleanCouleurs.vertEco,
                    ),
                  );
                }
              },
              child: const Text('Envoyer', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}