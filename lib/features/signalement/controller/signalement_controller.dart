import 'package:flutter/material.dart';
import '../models/signalement_model.dart';
import '../models/notification_model.dart';
import '../data/signalement_service.dart';

class SignalementController extends ChangeNotifier {
  final SignalementService _service = SignalementService();

  List<Signalement> mesSignalementsListe = [];
  List<Signalement> aTraiterListe = [];
  List<Signalement> historiqueListe = [];
  List<AppNotification> notificationsListe = [];

  int get notificationsNonLues => notificationsListe.where((n) => !n.lu).length;
  int get signalementsNonTraites =>
      aTraiterListe.where((s) => s.statut == 'en_attente').length;

  bool enChargement = false;
  String? messageErreur;

  // ---------- Citoyen ----------
  Future<void> chargerMesSignalements() async {
    enChargement = true;
    messageErreur = null;
    notifyListeners();
    try {
      mesSignalementsListe = await _service.mesSignalements();
    } catch (e) {
      messageErreur = 'Impossible de charger tes signalements';
    }
    enChargement = false;
    notifyListeners();
  }

  Future<bool> creerSignalement({
    required String description,
    required String quartier,
    String? precision,
    required String photoUrl,
    double? latitude,
    double? longitude,
  }) async {
    enChargement = true;
    messageErreur = null;
    notifyListeners();
    try {
      final nouveau = Signalement(
        id: '',
        description: description,
        statut: 'en_attente',
        photoUrl: photoUrl,
        latitude: latitude,
        longitude: longitude,
        quartier: quartier,
        precision: precision,
        archive: false,
        citoyenId: '',
        dateCreation: '',
      );
      final cree = await _service.creerSignalement(nouveau);
      mesSignalementsListe.insert(0, cree);
      enChargement = false;
      notifyListeners();
      return true;
    } catch (e) {
      messageErreur = e.toString().replaceFirst('Exception: ', '');
      enChargement = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> modifierSignalement(
    String id, {
    String? description,
    String? quartier,
    String? precision,
  }) async {
    try {
      await _service.modifierSignalement(
        id,
        description: description,
        quartier: quartier,
        precision: precision,
      );
      await chargerMesSignalements();
      return true;
    } catch (e) {
      messageErreur = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> annulerSignalement(String id) async {
    try {
      await _service.annulerSignalement(id);
      mesSignalementsListe.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      messageErreur = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> archiverSignalement(String id) async {
    await _service.archiverSignalement(id);
    mesSignalementsListe.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  // ---------- Agent ----------
  Future<void> chargerATraiter() async {
    enChargement = true;
    notifyListeners();
    try {
      aTraiterListe = await _service.aTraiter();
    } catch (e) {
      messageErreur = 'Impossible de charger';
    }
    enChargement = false;
    notifyListeners();
  }

  Future<void> chargerHistoriqueAgent() async {
    enChargement = true;
    notifyListeners();
    try {
      historiqueListe = await _service.historiqueAgent();
    } catch (e) {
      messageErreur = 'Impossible de charger';
    }
    enChargement = false;
    notifyListeners();
  }

  Future<bool> changerStatutAgent(
    String id,
    String statut, {
    String? motifRejet,
  }) async {
    try {
      await _service.changerStatut(id, statut, motifRejet: motifRejet);
      aTraiterListe.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      messageErreur = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ---------- Notifications ----------
  void _definirLu(String id, bool lu) {
    final i = notificationsListe.indexWhere((n) => n.id == id);
    if (i == -1) return;
    notificationsListe[i] = notificationsListe[i].copyWith(lu: lu);
    notifyListeners();
  }

  Future<void> marquerNotificationLue(String id) async {
    final trouvees = notificationsListe.where((n) => n.id == id);
    if (trouvees.isEmpty || trouvees.first.lu) return;
    _definirLu(id, true);
    try {
      await _service.marquerLue(id);
    } catch (e) {
      _definirLu(id, false);
    }
  }

  Future<void> marquerToutesNotificationsLues() async {
    if (notificationsNonLues == 0) return;
    notificationsListe = notificationsListe.map((n) => n.copyWith(lu: true)).toList();
    notifyListeners();
    try {
      await _service.marquerToutesLues();
    } catch (e) {
      await chargerNotifications();
    }
  }

  Future<Signalement?> chargerSignalement(String id) async {
    try {
      return await _service.getSignalementParId(id);
    } catch (e) {
      return null;
    }
  }

  Future<void> chargerNotifications([String? destinataire]) async {
    enChargement = true;
    notifyListeners();
    try {
      notificationsListe = await _service.listerNotifications();
    } catch (e) {
      messageErreur = 'Impossible de charger';
    }
    enChargement = false;
    notifyListeners();
  }
}
