import 'package:clean237_frontend/features/utilisateur/models/citoyen_stats_model.dart';

abstract class CitoyenRepository {
  Future<CitoyenStatsModel> chargerStats();
}