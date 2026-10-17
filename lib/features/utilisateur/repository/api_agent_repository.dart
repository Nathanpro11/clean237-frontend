import 'package:clean237_frontend/features/utilisateur/models/agent_stats_model.dart';
import 'package:clean237_frontend/features/utilisateur/repository/agent_repository.dart';
import 'package:clean237_frontend/utils/api_client.dart';

/// Implémentation réelle d'AgentRepository (backend Express).
class ApiAgentRepository implements AgentRepository {
  @override
  Future<AgentStatsModel> chargerStats() async {
    final data = await ApiClient.get('/utilisateurs/dashboard/stats/${ApiClient.userId}');
    final ind = (data['statistiques']?['Indicateurs'] ?? <String, dynamic>{}) as Map<String, dynamic>;

    final precedente = ind['connexionPrecedente'];
    return AgentStatsModel(
      secteurAffecte: ind['zonePriseEnCharge'] as String?,
      matricule: ind['matricule'] as String?,
      connexionsAujourdHui: (ind['connexionsAujourdhui'] as num?)?.toInt() ?? 0,
      actionsEnregistrees: (ind['actionsEnregistrees'] as num?)?.toInt() ?? 0,
      connexionPrecedente: precedente is String ? DateTime.tryParse(precedente) : null,
    );
  }
}