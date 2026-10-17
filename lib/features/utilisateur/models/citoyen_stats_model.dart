/// Statistiques RÉELLES du citoyen connecté (ancienneté du compte + journal d'audit).
class CitoyenStatsModel {
  final DateTime? membreDepuis;
  final DateTime? connexionPrecedente;
  final int actionsEnregistrees;

  const CitoyenStatsModel({
    required this.membreDepuis,
    required this.connexionPrecedente,
    required this.actionsEnregistrees,
  });
}