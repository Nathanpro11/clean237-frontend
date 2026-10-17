import 'dart:convert';

import '../exceptions/app_exception.dart';
import 'admin_remote_data_source.dart';

class AdminMockDataSource implements AdminRemoteDataSource {
  AdminMockDataSource() {
    _seed();
  }

  static const _zoneIds = [
    '66d5f1a2c2b8d61c5e8e0001',
    '66d5f1a2c2b8d61c5e8e0002',
    '66d5f1a2c2b8d61c5e8e0003',
    '66d5f1a2c2b8d61c5e8e0004',
    '66d5f1a2c2b8d61c5e8e0005',
    '66d5f1a2c2b8d61c5e8e0006',
    '66d5f1a2c2b8d61c5e8e0007',
    '66d5f1a2c2b8d61c5e8e0008',
    '66d5f1a2c2b8d61c5e8e0009',
    '66d5f1a2c2b8d61c5e8e0010',
    '66d5f1a2c2b8d61c5e8e0011',
    '66d5f1a2c2b8d61c5e8e0012',
  ];

  static const _zoneNames = [
    'Mfoundi Centre',
    'Biyem-Assi',
    'Bastos',
    'Mokolo Marché',
    'Ngoa-Ekellé',
    'Nkolbisson',
    'Omnisports',
    'Melen',
    'Essos',
    'Tsinga',
    'Mvog-Ada',
    'Mimboman',
  ];

  static const _severityScores = [
    90,
    68,
    15,
    82,
    8,
    44,
    20,
    33,
    30,
    12,
    48,
    25,
  ];

  final List<Map<String, dynamic>> _zones = [];
  final List<Map<String, dynamic>> _alerts = [];
  final List<Map<String, dynamic>> _analyses = [];
  final List<Map<String, dynamic>> _reports = [];
  final List<Map<String, dynamic>> _environmentalData = [];
  var _idCounter = 100;

  @override
  Future<Map<String, dynamic>> getDashboard() async {
    final byType = <String, int>{};
    for (final item in _environmentalData) {
      final type = item['type'] as String;
      byType[type] = (byType[type] ?? 0) + 1;
    }
    final activeAlerts = _alerts
        .where((item) => item['statut'] == 'active')
        .length;
    return _json({
      'message': 'Dashboard récupéré avec succès',
      'dashboard': {
        'totalZones': _zones.length,
        'totalDataPoints': _environmentalData.length,
        'dataByType': byType,
        'totalAnalyses': _analyses.length,
        'analysesWithResult': _analyses
            .where((item) => (item['resultat'] as String).isNotEmpty)
            .length,
        'totalReports': _reports.length,
        'reportsWithStats': _reports
            .where((item) => item['statistiques'] is Map)
            .length,
        'zonesCritiques': _zones
            .where((item) => item['niveau'] == 'critique')
            .length,
        'alertesActives': activeAlerts,
      },
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getProblematicZones() async {
    return _zones
        .map((zone) {
          final zoneId = zone['_id'] as String;
          final alerts = _alerts
              .where(
                (alert) =>
                    alert['zoneId'] == zoneId && alert['statut'] == 'active',
              )
              .length;
          final points = _environmentalData
              .where((point) => point['zoneId'] == zoneId)
              .toList();
          return {
            'zoneId': zoneId,
            'nom': zone['nom'],
            'score': zone['score'],
            'niveau': zone['niveau'],
            'details': {
              'alertScore': zone['score'],
              'alertCount': alerts,
              'dataCount': points.length,
              'derniereDonnee': points.isEmpty ? null : points.first['date'],
            },
          };
        })
        .toList(growable: false)
      ..sort((a, b) => (b['score'] as num).compareTo(a['score'] as num));
  }

  @override
  Future<List<Map<String, dynamic>>> getZones() async =>
      _copyList(_zones.map((zone) => {'_id': zone['_id'], 'nom': zone['nom']}));

  @override
  Future<Map<String, dynamic>> getZoneDetails(String zoneId) async {
    final zone = _find(_zones, zoneId);
    final points = _environmentalData
        .where((item) => item['zoneId'] == zoneId)
        .toList();
    final severity = zone['score'] as int;
    final activeAlerts = _alerts
        .where((item) => item['zoneId'] == zoneId && item['statut'] == 'active')
        .length;
    final now = DateTime.now().toUtc();
    return _json({
      'message': 'Détails de la zone récupérés avec succès',
      'zone': {
        ...zone,
        'evolutionPoints': 2,
        'derniereMiseAJour': points.isEmpty ? null : points.first['date'],
        'evolution30Jours': List.generate(30, (index) {
          final pointDate = now.subtract(Duration(days: 29 - index));
          final score = (severity - ((29 - index) % 5) * 2).clamp(0, 100);
          return {'date': pointDate.toIso8601String(), 'score': score};
        }),
        'alertCount': activeAlerts,
        'dataCount': points.length,
        'interpretation': zone['niveau'] == 'critique'
            ? 'Zone critique : $activeAlerts alertes actives.'
            : 'État de la zone : ${zone['niveau']}.',
        'priorites': activeAlerts == 0
            ? <String>[]
            : <String>['Traiter les $activeAlerts alertes actives'],
      },
    });
  }

  @override
  Future<Map<String, dynamic>> getEnvironmentalData({
    String? zoneId,
    String? type,
    int page = 1,
    int limit = 20,
    String sort = 'date',
    String order = 'desc',
  }) async {
    final filtered = _environmentalData.where((item) {
      return (zoneId == null || item['zoneId'] == zoneId) &&
          (type == null || item['type'] == type);
    }).toList();
    filtered.sort((a, b) {
      final comparison = (a[sort] ?? '').toString().compareTo(
        (b[sort] ?? '').toString(),
      );
      return order == 'asc' ? comparison : -comparison;
    });
    return _page(filtered, page, limit);
  }

  @override
  Future<Map<String, dynamic>> getEnvironmentalDataById(String id) async => {
    'message': 'Donnée récupérée avec succès',
    'donnee': _find(_environmentalData, id),
  };

  @override
  Future<Map<String, dynamic>> getAlerts({
    String? severity,
    String? zoneId,
    String? status,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    final query = search?.trim().toLowerCase() ?? '';
    final result = _alerts.where((alert) {
      return (severity == null || alert['severite'] == severity) &&
          (zoneId == null || alert['zoneId'] == zoneId) &&
          (status == null || alert['statut'] == status) &&
          (query.isEmpty ||
              '${alert['titre']} ${alert['sousTitre']} ${alert['zoneNom']}'
                  .toLowerCase()
                  .contains(query));
    }).toList();
    return _page(result, page, limit);
  }

  @override
  Future<Map<String, dynamic>> getAlertById(String id) async => {
    'message': 'Alerte récupérée avec succès',
    'alerte': _find(_alerts, id),
  };

  @override
  Future<Map<String, dynamic>> treatAlert(String id) async {
    final alert = _find(_alerts, id);
    alert['statut'] = 'traitee';
    return {'message': 'Alerte traitée avec succès', 'alerte': _json(alert)};
  }

  @override
  Future<Map<String, dynamic>> generateAnalysis({
    String? type,
    String? zoneId,
    DateTime? start,
    DateTime? end,
  }) async {
    final points = _environmentalData.where((item) {
      final date = DateTime.parse(item['date'] as String);
      return (zoneId == null || item['zoneId'] == zoneId) &&
          (start == null || !date.isBefore(start)) &&
          (end == null || !date.isAfter(end));
    }).toList();
    if (points.isEmpty) {
      throw const NotFoundException(
        'Aucune donnée ne correspond à la période sélectionnée.',
      );
    }
    final byType = <String, List<num>>{};
    for (final point in points) {
      byType
          .putIfAbsent(point['type'] as String, () => [])
          .add(point['valeur'] as num);
    }
    final stats = <String, dynamic>{};
    for (final entry in byType.entries) {
      final values = entry.value;
      final sum = values.fold<num>(0, (total, value) => total + value);
      stats[entry.key] = {
        'count': values.length,
        'moyenne': sum / values.length,
        'minimum': values.reduce((a, b) => a < b ? a : b),
        'maximum': values.reduce((a, b) => a > b ? a : b),
        'somme': sum,
        'unite': points.firstWhere(
          (item) => item['type'] == entry.key,
        )['unite'],
      };
    }
    final id = _nextId();
    final zone = zoneId == null ? null : _find(_zones, zoneId);
    final now = DateTime.now().toUtc().toIso8601String();
    final analysis = {
      '_id': id,
      'type': type ?? 'analyse',
      ...?_optionalField('zoneId', zoneId),
      ...?_optionalField('zoneNom', zone?['nom']),
      'periode': {
        'start': (start ?? DateTime.now().subtract(const Duration(days: 7)))
            .toUtc()
            .toIso8601String(),
        'end': (end ?? DateTime.now()).toUtc().toIso8601String(),
      },
      'resultat': 'Analyse de ${points.length} points de données.',
      'indicateurs': {'totalPoints': points.length, 'parType': stats},
      'donneesUtilisees': points.map((item) => item['_id']).toList(),
      'createdAt': now,
      'updatedAt': now,
    };
    _analyses.insert(0, analysis);
    return {
      'message': 'Analyse générée avec succès',
      'analyse': _json(analysis),
    };
  }

  @override
  Future<Map<String, dynamic>> getAnalysisById(String id) async => {
    'message': 'Analyse récupérée avec succès',
    'analyse': _json(_find(_analyses, id)),
  };

  @override
  Future<String?> deleteAnalysis(String id) async {
    if (_reports.any(
      (report) => _linkedAnalysisId(report['analyseId']) == id,
    )) {
      throw const ConflictException(
        'Cette analyse est liée à un rapport et ne peut pas être supprimée.',
      );
    }
    _analyses.removeWhere((item) => item['_id'] == id);
    return 'Analyse supprimée avec succès';
  }

  @override
  Future<Map<String, dynamic>> generateReport({
    required String title,
    String? description,
    required String analysisId,
    String? type,
    required String format,
  }) async {
    final analysis = _find(_analyses, analysisId);
    final zoneId = analysis['zoneId'];
    final zones = zoneId == null
        ? <Map<String, dynamic>>[]
        : [_find(_zones, zoneId.toString())];
    final now = DateTime.now().toUtc().toIso8601String();
    final report = {
      '_id': _nextId(),
      'titre': title,
      ...?_optionalField('description', description),
      'type': type ?? 'synthese',
      'statut': 'pret',
      'format': format,
      'zones': zones
          .map((zone) => {'_id': zone['_id'], 'nom': zone['nom']})
          .toList(),
      'analyseId': analysis,
      'statistiques': analysis['indicateurs'],
      'createdAt': now,
      'updatedAt': now,
    };
    _reports.insert(0, report);
    return {'message': 'Rapport généré avec succès', 'report': _json(report)};
  }

  @override
  Future<Map<String, dynamic>> getReports({
    int page = 1,
    int limit = 10,
    String sort = 'createdAt',
    String order = 'desc',
    String? search,
    String? status,
    String? type,
    String? zoneId,
  }) async {
    final query = search?.trim().toLowerCase() ?? '';
    final reports = _reports.where((report) {
      final zoneMatch =
          zoneId == null ||
          (report['zones'] as List).any((zone) => zone['_id'] == zoneId);
      return (status == null || report['statut'] == status) &&
          (type == null || report['type'] == type) &&
          zoneMatch &&
          (query.isEmpty ||
              '${report['titre']} ${report['description'] ?? ''}'
                  .toLowerCase()
                  .contains(query));
    }).toList();
    reports.sort((a, b) {
      final comparison = (a[sort] ?? '').toString().compareTo(
        (b[sort] ?? '').toString(),
      );
      return order == 'asc' ? comparison : -comparison;
    });
    return _page(reports, page, limit);
  }

  @override
  Future<Map<String, dynamic>> getReportById(String id) async => {
    'message': 'Rapport récupéré avec succès',
    'report': _json(_find(_reports, id)),
  };

  @override
  Future<String?> deleteReport(String id) async {
    _find(_reports, id);
    _reports.removeWhere((item) => item['_id'] == id);
    return 'Rapport supprimé avec succès';
  }

  @override
  Future<Map<String, dynamic>> updateReportStatus(
    String id,
    String status,
  ) async {
    final report = _find(_reports, id);
    report['statut'] = status;
    report['updatedAt'] = DateTime.now().toUtc().toIso8601String();
    return {
      'message': 'Statut du rapport mis à jour avec succès',
      'report': _json(report),
    };
  }

  @override
  Future<List<int>> exportReport(String id, String format) async {
    final report = _find(_reports, id);
    if (format == 'csv') {
      final statistics = report['statistiques'] as Map;
      final rows = <String>['Type;Nombre;Moyenne;Minimum;Maximum;Somme;Unité'];
      final perType = statistics['parType'] as Map? ?? const {};
      for (final entry in perType.entries) {
        final item = entry.value as Map;
        rows.add(
          '${entry.key};${item['count']};${item['moyenne']};${item['minimum']};'
          '${item['maximum']};${item['somme']};${item['unite'] ?? ''}',
        );
      }
      return utf8.encode('\uFEFF${rows.join('\r\n')}');
    }
    return _minimalPdf;
  }

  static const _minimalPdf = <int>[
    37,
    80,
    68,
    70,
    45,
    49,
    46,
    49,
    10,
    49,
    32,
    48,
    32,
    111,
    98,
    106,
    10,
    60,
    60,
    32,
    47,
    84,
    121,
    112,
    101,
    32,
    47,
    67,
    97,
    116,
    97,
    108,
    111,
    103,
    32,
    47,
    80,
    97,
    103,
    101,
    115,
    32,
    50,
    32,
    48,
    32,
    82,
    32,
    62,
    62,
    10,
    101,
    110,
    100,
    111,
    98,
    106,
    10,
    50,
    32,
    48,
    32,
    111,
    98,
    106,
    10,
    60,
    60,
    32,
    47,
    84,
    121,
    112,
    101,
    32,
    47,
    80,
    97,
    103,
    101,
    115,
    32,
    47,
    75,
    105,
    100,
    115,
    32,
    91,
    51,
    32,
    48,
    32,
    82,
    93,
    32,
    47,
    67,
    111,
    117,
    110,
    116,
    32,
    49,
    32,
    62,
    62,
    10,
    101,
    110,
    100,
    111,
    98,
    106,
    10,
    51,
    32,
    48,
    32,
    111,
    98,
    106,
    10,
    60,
    60,
    32,
    47,
    84,
    121,
    112,
    101,
    32,
    47,
    80,
    97,
    103,
    101,
    32,
    47,
    80,
    97,
    114,
    101,
    110,
    116,
    32,
    50,
    32,
    48,
    32,
    82,
    32,
    47,
    77,
    101,
    100,
    105,
    97,
    66,
    111,
    120,
    32,
    91,
    48,
    32,
    48,
    32,
    51,
    48,
    48,
    32,
    52,
    48,
    48,
    93,
    32,
    62,
    62,
    10,
    101,
    110,
    100,
    111,
    98,
    106,
    10,
    116,
    114,
    105,
    108,
    101,
    114,
    10,
    60,
    60,
    32,
    47,
    82,
    111,
    111,
    116,
    32,
    49,
    32,
    48,
    32,
    82,
    32,
    62,
    62,
    10,
    37,
    37,
    69,
    79,
    70,
  ];

  Map<String, dynamic> _page(
    List<Map<String, dynamic>> items,
    int page,
    int limit,
  ) {
    final start = (page - 1) * limit;
    final end = (start + limit).clamp(0, items.length);
    return _json({
      'message': 'Liste récupérée avec succès',
      'data': start >= items.length
          ? <Map<String, dynamic>>[]
          : items.sublist(start, end),
      'pagination': {
        'page': page,
        'limit': limit,
        'total': items.length,
        'totalPages': (items.length / limit).ceil(),
      },
    });
  }

  Map<String, dynamic> _find(List<Map<String, dynamic>> items, String id) {
    for (final item in items) {
      if (item['_id'] == id) return item;
    }
    throw const NotFoundException('Ressource introuvable.');
  }

  String _nextId() {
    _idCounter++;
    return '66d5f1a2c2b8d61c5e8e${_idCounter.toString().padLeft(4, '0')}';
  }

  Map<String, dynamic>? _optionalField(String key, Object? value) =>
      value == null ? null : <String, dynamic>{key: value};

  String? _linkedAnalysisId(dynamic value) =>
      value is Map ? value['_id']?.toString() : value?.toString();

  Map<String, dynamic> _json(Map<String, dynamic> value) =>
      Map<String, dynamic>.from(jsonDecode(jsonEncode(value)) as Map);

  List<Map<String, dynamic>> _copyList(Iterable<Map<String, dynamic>> value) =>
      value.map(_json).toList(growable: false);

  void _seed() {
    for (var i = 0; i < _zoneIds.length; i++) {
      final severity = _severityScores[i];
      _zones.add({
        '_id': _zoneIds[i],
        'nom': _zoneNames[i],
        'score': severity,
        'niveau': severity >= 80
            ? 'critique'
            : severity >= 60
            ? 'problématique'
            : severity >= 40
            ? 'à surveiller'
            : 'normal',
      });
      for (var point = 0; point < 3; point++) {
        final date = DateTime.now().toUtc().subtract(
          Duration(hours: i * 3 + point),
        );
        _environmentalData.add({
          '_id':
              '66d5f1a2c2b8d61c5e8e${(200 + i * 3 + point).toString().padLeft(4, '0')}',
          'type': point == 0
              ? 'alerte'
              : point == 1
              ? 'dechet'
              : 'collecte',
          'zoneId': _zoneIds[i],
          'valeur': severity + point,
          'unite': point == 0 ? 'signalements' : 'kg',
          'date': date.toIso8601String(),
          'source': 'Saisie terrain',
          'createdAt': date.toIso8601String(),
          'updatedAt': date.toIso8601String(),
        });
      }
    }
    for (var i = 0; i < 7; i++) {
      final zoneIndex = i % 4;
      final zone = _zones[zoneIndex];
      _alerts.add({
        '_id': '66d5f1a2c2b8d61c5e8e${(300 + i).toString().padLeft(4, '0')}',
        'titre': 'Alerte · ${zone['nom']}',
        'sousTitre': 'Signalement',
        'zoneId': zone['_id'],
        'zoneNom': zone['nom'],
        'date': DateTime.now()
            .toUtc()
            .subtract(Duration(hours: i + 1))
            .toIso8601String(),
        'severite': (zone['niveau'] == 'critique')
            ? 'critique'
            : (zone['niveau'] == 'normal' ? 'info' : 'avertissement'),
        'statut': i == 6 ? 'traitee' : 'active',
      });
    }
  }
}
