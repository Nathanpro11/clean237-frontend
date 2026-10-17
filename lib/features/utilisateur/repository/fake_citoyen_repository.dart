import 'package:clean237_frontend/features/utilisateur/models/citoyen_stats_model.dart';
import 'package:clean237_frontend/features/utilisateur/repository/citoyen_repository.dart';

/// Données de démonstration (mode hors ligne uniquement).
class FakeCitoyenRepository implements CitoyenRepository {
  @override
  Future<CitoyenStatsModel> chargerStats() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return CitoyenStatsModel(
      membreDepuis: DateTime.now().subtract(const Duration(days: 30)),
      connexionPrecedente: DateTime.now().subtract(const Duration(days: 1)),
      actionsEnregistrees: 3,
    );
  }
}