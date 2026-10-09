/// Statistiques du tableau de bord Agent de terrain.
class AgentStatsModel {
  final int missionsAujourdHui;
  final int collectesTerminees;
  final String secteurAffecte;

  const AgentStatsModel({
    required this.missionsAujourdHui,
    required this.collectesTerminees,
    required this.secteurAffecte,
  });
}