String tempsEcoule(String dateIso) {
  try {
    final date = DateTime.parse(dateIso).toLocal();
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'A l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return '${date.day}/${date.month}/${date.year}';
  } catch (e) {
    return '';
  }
}
