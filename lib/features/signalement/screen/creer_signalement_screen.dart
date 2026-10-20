import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/signalement_controller.dart';
import '../data/constants.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CreerSignalementScreen extends StatefulWidget {
  const CreerSignalementScreen({super.key});
  @override
  State<CreerSignalementScreen> createState() => _CreerSignalementScreenState();
}

class _CreerSignalementScreenState extends State<CreerSignalementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _precisionController = TextEditingController();
  String? _quartierSaisi;
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
                onTap: () async {
                  final photo = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                    imageQuality: 70,
                  );
                  if (photo != null) setState(() => _photoUrl = photo.path);
                },
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
                  child: _photoUrl == null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.grey,
                              size: 28,
                            ),
                            SizedBox(height: 8),
                            Text('Ajouter une photo'),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            File(_photoUrl!),
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Quartier *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue v) {
                  if (v.text.isEmpty) return quartiersDisponibles;
                  return quartiersDisponibles.where(
                    (q) => q.contains(v.text.toUpperCase()),
                  );
                },
                onSelected: (s) => _quartierSaisi = s,
                fieldViewBuilder:
                    (context, controller, focusNode, onSubmitted) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        inputFormatters: [MajusculeFormatter()],
                        onChanged: (v) => _quartierSaisi = v,
                        decoration: InputDecoration(
                          hintText: 'Ex : BASTOS',
                          filled: true,
                          fillColor: const Color(0xFFF5F6F4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Le quartier est obligatoire'
                            : null,
                      );
                    },
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
                            quartier: _quartierSaisi!,
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
