import 'package:clean237_frontend/features/utilisateur/models/utilisateur_model.dart';
import 'package:clean237_frontend/features/utilisateur/repository/auth_repository.dart';
import 'package:clean237_frontend/utils/api_client.dart';

/// Implémentation réelle d'AuthRepository (backend Express, port 3000).
class ApiAuthRepository implements AuthRepository {
  AuthResult _echec(Object e) => AuthResult(
        succes: false,
        messageErreur: e is ApiException ? e.message : 'Réponse inattendue du serveur.',
      );

  @override
  Future<AuthResult> login(String email, String motDepasse) async {
    try {
      final data = await ApiClient.post('/utilisateurs/login', {
        'email': email.trim().toLowerCase(),
        'motDepasse': motDepasse,
      });
      final utilisateur = UtilisateurModel.fromJson(data['data'] as Map<String, dynamic>);
      final token = data['token'] as String;
      ApiClient.ouvrirSession(token: token, userId: utilisateur.id);
      return AuthResult(succes: true, token: token, utilisateur: utilisateur);
    } catch (e) {
      // Le blocage anti-bruteforce (429) est appliqué par le serveur : on affiche son
      // message sans verrouiller le formulaire (sinon il resterait bloqué après 15 min).
      return _echec(e);
    }
  }

  @override
  Future<AuthResult> inscrireUnUtilisateur({
    required String nom,
    required String email,
    required String telephone,
    required String motDepasse,
    required String profil,
    String? matricule,
    String? zoneAffectee,
  }) async {
    try {
      // L'inscription publique crée toujours un citoyen (forcé côté serveur).
      await ApiClient.post('/utilisateurs/create', {
        'nom': nom,
        'email': email,
        'telephone': telephone,
        'motDepasse': motDepasse,
      });
      return AuthResult(succes: true);
    } catch (e) {
      return _echec(e);
    }
  }

  @override
  Future<AuthResult> modifierProfil({required String nom, required String telephone}) async {
    try {
      final data = await ApiClient.put(
        '/utilisateurs/update_by_id/${ApiClient.userId}',
        {'nom': nom, 'telephone': telephone},
      );
      return AuthResult(
        succes: true,
        utilisateur: UtilisateurModel.fromJson(data['data'] as Map<String, dynamic>),
      );
    } catch (e) {
      return _echec(e);
    }
  }

  @override
  Future<AuthResult> changerMotDePasse({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
  }) async {
    try {
      await ApiClient.put('/utilisateurs/change-password/${ApiClient.userId}', {
        'ancienMotDePasse': ancienMotDePasse,
        'nouveauMotDePasse': nouveauMotDePasse,
      });
      return AuthResult(succes: true);
    } catch (e) {
      return _echec(e);
    }
  }

  @override
  Future<AuthResult> demanderCodeReinitialisation({required String email}) async {
    try {
      await ApiClient.post('/utilisateurs/reset-password-request', {
        'email': email.trim().toLowerCase(),
      });
      return AuthResult(succes: true);
    } catch (e) {
      return _echec(e);
    }
  }

  @override
  Future<AuthResult> confirmerReinitialisation({
    required String email,
    required String code,
    required String nouveauMotDePasse,
  }) async {
    try {
      await ApiClient.post('/utilisateurs/reset-password-confirm', {
        'email': email.trim().toLowerCase(),
        'code': code.trim(),
        'nouveauMotDePasse': nouveauMotDePasse,
      });
      return AuthResult(succes: true);
    } catch (e) {
      return _echec(e);
    }
  }
}