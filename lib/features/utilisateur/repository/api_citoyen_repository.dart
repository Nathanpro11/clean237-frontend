import 'package:clean237_frontend/features/utilisateur/models/citoyen_stats_model.dart';
import 'package:clean237_frontend/features/utilisateur/repository/citoyen_repository.dart';
import 'package:clean237_frontend/utils/api_client.dart';

/// Implémentation réelle de CitoyenRepository (backend Express).
class ApiCitoyenRepository implements CitoyenRepository {
  DateTime? _date(dynamic valeur) => valeur is String ? DateTime.tryParse(valeur) : null;

  @override
  Future<CitoyenStatsModel> chargerStats() async {
    final data = await ApiClient.get('/utilisateurs/dashboard/stats/${ApiClient.userId}');
    final ind = (data['statistiques']?['Indicateurs'] ?? <String, dynamic>{}) as Map<String, dynamic>;

    return CitoyenStatsModel(
      membreDepuis: _date(ind['membreDepuis']),
      connexionPrecedente: _date(ind['connexionPrecedente']),
      actionsEnregistrees: (ind['actionsEnregistrees'] as num?)?.toInt() ?? 0,
    );
  }
}