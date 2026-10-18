import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/signalement_controller.dart';
import '../models/signalement_model.dart';
import '../data/constants.dart';

class ModifierSignalementScreen extends StatefulWidget {
  final Signalement signalement;
  const ModifierSignalementScreen({super.key, required this.signalement});
  @override
  State<ModifierSignalementScreen> createState() =>
      _ModifierSignalementScreenState();
}

class _ModifierSignalementScreenState extends State<ModifierSignalementScreen> {
  late TextEditingController _descriptionController;
  late String _quartierChoisi;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.signalement.description,
    );
    _quartierChoisi = widget.signalement.quartier;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SignalementController>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF27AE60),
        title: const Text('Modifier', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _quartierChoisi,
              items: quartiersDisponibles
                  .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                  .toList(),
              onChanged: (v) => setState(() => _quartierChoisi = v!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                ),
                onPressed: () async {
                  final ok = await controller.modifierSignalement(
                    widget.signalement.id,
                    description: _descriptionController.text.trim(),
                    quartier: _quartierChoisi,
                  );
                  if (ok && context.mounted) Navigator.pop(context);
                },
                child: const Text(
                  'Enregistrer',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
