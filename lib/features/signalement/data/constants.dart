import 'package:flutter/services.dart';

// Remplace ces 2 valeurs par de vrais _id generes via tes tests Postman

// (/api/dev/citoyens et /api/dev/agents). Une fois l'authentification
// branchee (module Utilisateurs), ces valeurs viendront automatiquement
// du compte connecte au lieu d'etre fixes ici.

const List<String> quartiersDisponibles = [
  'BASTOS',
  'MVAN',
  'ESSOS',
  'NGOUSSO',
  'NKOLBISSON',
  'SOA',
  'EMOMBO',
  'MENDONG',
  'EKOUNOU',
  'MVOLYE',
  'TSINGA',
  'NSAM',
  'ETOUDI',
  'OLEMBE',
  'MESSA',
  'BIYEM-ASSI',
  'ODZA',
  'NKOLNDONGO',
  'AWAE',
  'NGOA-EKELLE',
];

class MajusculeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
