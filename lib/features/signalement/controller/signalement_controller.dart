import 'package:flutter/material.dart';
import '../models/signalement_model.dart';
import '../models/notification_model.dart';
import '../data/signalement_service.dart';
import '../data/constants.dart';

class SignalementController extends ChangeNotifier {
  final SignalementService _service = SignalementService();

  List<Signalement> mesSignalementsListe = [];
  List<Signalement> aTraiterListe = [];
  List<Signalement> historiqueListe = [];
  List<AppNotification> notificationsListe = [];

  bool enChargement = false;
  String? messageErreur;

  // ---------- Citoyen ----------
  Future<void> chargerMesSignalements() async {
    enChargement = true;
    messageErreur = null;
    notifyListeners();
    try {
      mesSignalementsListe = await _service.mesSignalements(citoyenIdTest);
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
        quartier: quartier,
        precision: precision,
        archive: false,
        citoyenId: citoyenIdTest,
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
      aTraiterListe = await _service.aTraiter(agentIdTest);
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
      historiqueListe = await _service.historiqueAgent(agentIdTest);
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
  Future<void> chargerNotifications(String destinataire) async {
    enChargement = true;
    notifyListeners();
    try {
      notificationsListe = await _service.listerNotifications(destinataire);
    } catch (e) {
      messageErreur = 'Impossible de charger';
    }
    enChargement = false;
    notifyListeners();
  }
}
