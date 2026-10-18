import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/signalement_controller.dart';
import '../data/constants.dart';

class CreerSignalementScreen extends StatefulWidget {
  const CreerSignalementScreen({super.key});
  @override
  State<CreerSignalementScreen> createState() => _CreerSignalementScreenState();
}

class _CreerSignalementScreenState extends State<CreerSignalementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _precisionController = TextEditingController();
  String? _quartierChoisi;
  String? _photoUrl; // simule l'upload, pas de vrai stockage de fichier encore

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SignalementController>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF27AE60),
        title: const Text(
          'Nouveau signalement',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Photo *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => setState(
                  () => _photoUrl =
                      'https://exemple.com/photo-${DateTime.now().millisecondsSinceEpoch}.jpg',
                ),
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F4),
                    border: Border.all(
                      color: const Color(0xFFCBD2CC),
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _photoUrl == null
                            ? Icons.camera_alt_outlined
                            : Icons.check_circle,
                        color: _photoUrl == null
                            ? Colors.grey
                            : const Color(0xFF27AE60),
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _photoUrl == null
                            ? 'Ajouter une photo'
                            : 'Photo ajoutée',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Quartier *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _quartierChoisi,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF5F6F4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: quartiersDisponibles
                    .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                    .toList(),
                onChanged: (v) => setState(() => _quartierChoisi = v),
                validator: (v) =>
                    v == null ? 'Le quartier est obligatoire' : null,
              ),
              const SizedBox(height: 20),
              const Text(
                'Précision (optionnel)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _precisionController,
                decoration: InputDecoration(
                  hintText: 'Ex : près du marché',
                  filled: true,
                  fillColor: const Color(0xFFFAFAF9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Description *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Décrivez le problème...',
                  filled: true,
                  fillColor: const Color(0xFFFAFAF9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'La description est obligatoire';
                  if (v.trim().length < 5) return 'Au moins 5 caractères';
                  if (v.trim().split(RegExp(r'\s+')).length > 200)
                    return 'Maximum 200 mots';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (controller.messageErreur != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    controller.messageErreur!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: controller.enChargement
                      ? null
                      : () async {
                          if (_photoUrl == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('La photo est obligatoire'),
                              ),
                            );
                            return;
                          }
                          if (!_formKey.currentState!.validate()) return;
                          final succes = await controller.creerSignalement(
                            description: _descriptionController.text.trim(),
                            quartier: _quartierChoisi!,
                            precision: _precisionController.text.trim(),
                            photoUrl: _photoUrl!,
                          );
                          if (succes && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Signalement envoyé avec succès'),
                                backgroundColor: Color(0xFF27AE60),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                  child: controller.enChargement
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Envoyer le signalement',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
