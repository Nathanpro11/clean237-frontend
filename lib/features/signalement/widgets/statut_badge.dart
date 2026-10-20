import 'package:flutter/material.dart';

class StatutBadge extends StatelessWidget {
  final String statut;
  const StatutBadge({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    late Color fond;
    late Color texte;
    late String label;
    switch (statut) {
      case 'pris_en_charge':
        fond = const Color(0xFFDCE8FF);
        texte = const Color(0xFF2355C7);
        label = 'Pris en charge';
        break;
      case 'resolu':
        fond = const Color(0xFFDCEFE6);
        texte = const Color(0xFF27AE60);
        label = 'Résolu';
        break;
      case 'rejete':
        fond = const Color(0xFFFADBD8);
        texte = const Color(0xFFB3261E);
        label = 'Rejeté';
        break;
      default:
        fond = const Color(0xFFFCEFD9);
        texte = const Color(0xFF9A5B10);
        label = 'En attente';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: texte,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
