/// Statistiques RÉELLES de l'Agent de terrain (comptes + journal d'audit).
/// Les missions/collectes seront ajoutées avec le module correspondant.
class AgentStatsModel {
  final String? secteurAffecte;
  final String? matricule;
  final int connexionsAujourdHui;
  final int actionsEnregistrees;
  final DateTime? connexionPrecedente;

  const AgentStatsModel({
    required this.secteurAffecte,
    required this.matricule,
    required this.connexionsAujourdHui,
    required this.actionsEnregistrees,
    required this.connexionPrecedente,
  });
}