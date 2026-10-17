import 'package:clean237_frontend/features/utilisateur/models/agent_stats_model.dart';
import 'package:clean237_frontend/features/utilisateur/repository/agent_repository.dart';

/// Données de démonstration (mode hors ligne uniquement).
class FakeAgentRepository implements AgentRepository {
  @override
  Future<AgentStatsModel> chargerStats() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return AgentStatsModel(
      secteurAffecte: 'yaoundé vi',
      matricule: 'AGT-237-001',
      connexionsAujourdHui: 1,
      actionsEnregistrees: 3,
      connexionPrecedente: DateTime.now().subtract(const Duration(days: 1)),
    );
  }
}