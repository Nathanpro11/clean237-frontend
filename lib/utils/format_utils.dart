const List<String> _mois = [
  'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
  'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
];

/// "15 oct. 2026" (heure locale ; le serveur renvoie de l'UTC).
String formaterDate(DateTime date) {
  final d = date.toLocal();
  return '${d.day} ${_mois[d.month - 1]} ${d.year}';
}

/// "15 oct. 2026, 08:37"
String formaterDateHeure(DateTime date) {
  final d = date.toLocal();
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '${formaterDate(d)}, $h:$m';
}

/// "yaoundé vi" -> "Yaoundé Vi" (les zones sont stockées en minuscules côté serveur).
String capitaliserMots(String texte) {
  return texte
      .split(' ')
      .map((mot) => mot.isEmpty ? mot : '${mot[0].toUpperCase()}${mot.substring(1)}')
      .join(' ');
}