import 'package:clean237_frontend/features/utilisateur/models/agent_stats_model.dart';


abstract class AgentRepository {
  Future<AgentStatsModel> chargerStats();
}

