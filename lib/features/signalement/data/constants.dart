import 'package:flutter/services.dart';

// Remplace ces 2 valeurs par de vrais _id generes via tes tests Postman

// (/api/dev/citoyens et /api/dev/agents). Une fois l'authentification
// branchee (module Utilisateurs), ces valeurs viendront automatiquement
// du compte connecte au lieu d'etre fixes ici.
const String citoyenIdTest = '6ad64ed2f24a35b60b00a283';
const String agentIdTest = '6ad64ee8f24a35b60b00a284';

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
