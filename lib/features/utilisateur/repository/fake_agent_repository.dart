import 'package:clean237_frontend/features/utilisateur/models/agent_stats_model.dart';
import 'package:clean237_frontend/features/utilisateur/repository/agent_repository.dart';

class FakeAgentRepository implements AgentRepository {
  @override
  Future<AgentStatsModel> chargerStats() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const AgentStatsModel(
      missionsAujourdHui: 4,
      collectesTerminees: 3,
      secteurAffecte: 'Yaoundé VI',
    );
  }
}