import 'dart:convert';

import 'admin_remote_data_source.dart';
import 'api_client.dart';

class AdminApiDataSource implements AdminRemoteDataSource {
  AdminApiDataSource({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _client.get<Map<String, dynamic>>('/dashboard');
    return _map(response.data);
  }

  @override
  Future<List<Map<String, dynamic>>> getProblematicZones() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/dashboard/zones/problematic',
    );
    return _list(response.data?['zones']);
  }

  @override
  Future<List<Map<String, dynamic>>> getZones() async {
    final response = await _client.get<Map<String, dynamic>>('/zones');
    return _list(response.data?['zones']);
  }

  @override
  Future<Map<String, dynamic>> getZoneDetails(String zoneId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/zones/${Uri.encodeComponent(zoneId)}/details',
    );
    return _map(response.data);
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
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      'sort': sort,
      'order': order,
    };
    if (zoneId != null) query['zoneId'] = zoneId;
    if (type != null) query['type'] = type;
    final response = await _client.get<Map<String, dynamic>>(
      '/donnees-environnementales',
      queryParameters: query,
    );
    return _map(response.data);
  }

  @override
  Future<Map<String, dynamic>> getEnvironmentalDataById(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/donnees-environnementales/${Uri.encodeComponent(id)}',
    );
    return _map(response.data);
  }

  @override
  Future<Map<String, dynamic>> getAlerts({
    String? severity,
    String? zoneId,
    String? status,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      ...?_optionalParameter('severite', severity),
      ...?_optionalParameter('zoneId', zoneId),
      ...?_optionalParameter('statut', status),
      ...?_optionalParameter('search', search, omitEmpty: true),
    };
    final response = await _client.get<Map<String, dynamic>>(
      '/alertes',
      queryParameters: query,
    );
    return _map(response.data);
  }

  @override
  Future<Map<String, dynamic>> getAlertById(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/alertes/${Uri.encodeComponent(id)}',
    );
    return _map(response.data);
  }

  @override
  Future<Map<String, dynamic>> treatAlert(String id) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/alertes/${Uri.encodeComponent(id)}/traiter',
    );
    return _map(response.data);
  }

  @override
  Future<Map<String, dynamic>> generateAnalysis({
    String? type,
    String? zoneId,
    DateTime? start,
    DateTime? end,
  }) async {
    final payload = <String, dynamic>{};
    if (type != null) payload['type'] = type;
    if (zoneId != null) payload['zoneId'] = zoneId;
    if (start != null || end != null) {
      payload['periode'] = <String, dynamic>{
        if (start != null) 'start': start.toUtc().toIso8601String(),
        if (end != null) 'end': end.toUtc().toIso8601String(),
      };
    }
    final response = await _client.post<Map<String, dynamic>>(
      '/analyses/generate',
      data: payload,
    );
    return _map(response.data);
  }

  @override
  Future<Map<String, dynamic>> getAnalysisById(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/analyses/${Uri.encodeComponent(id)}',
    );
    return _map(response.data);
  }

  @override
  Future<String?> deleteAnalysis(String id) async {
    final response = await _client.delete<Map<String, dynamic>>(
      '/analyses/${Uri.encodeComponent(id)}',
    );
    return response.data?['message'] as String?;
  }

  @override
  Future<Map<String, dynamic>> generateReport({
    required String title,
    String? description,
    required String analysisId,
    String? type,
    required String format,
  }) async {
    final payload = <String, dynamic>{
      'titre': title,
      'analyseId': analysisId,
      'format': format,
    };
    if (description != null && description.isNotEmpty) {
      payload['description'] = description;
    }
    if (type != null) payload['type'] = type;
    final response = await _client.post<Map<String, dynamic>>(
      '/rapports/generate',
      data: payload,
    );
    return _map(response.data);
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
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      'sort': sort,
      'order': order,
      ...?_optionalParameter('search', search, omitEmpty: true),
      ...?_optionalParameter('statut', status),
      ...?_optionalParameter('type', type),
      ...?_optionalParameter('zoneId', zoneId),
    };
    final response = await _client.get<Map<String, dynamic>>(
      '/rapports',
      queryParameters: query,
    );
    return _map(response.data);
  }

  @override
  Future<Map<String, dynamic>> getReportById(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/rapports/${Uri.encodeComponent(id)}',
    );
    return _map(response.data);
  }

  @override
  Future<String?> deleteReport(String id) async {
    final response = await _client.delete<Map<String, dynamic>>(
      '/rapports/${Uri.encodeComponent(id)}',
    );
    return response.data?['message'] as String?;
  }

  @override
  Future<Map<String, dynamic>> updateReportStatus(
    String id,
    String status,
  ) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/rapports/${Uri.encodeComponent(id)}/statut',
      data: {'statut': status},
    );
    return _map(response.data);
  }

  @override
  Future<List<int>> exportReport(String id, String format) async {
    final response = await _client.getBytes(
      '/rapports/${Uri.encodeComponent(id)}/export',
      queryParameters: {'format': format},
    );
    final data = response.data ?? const <int>[];
    // Si le backend retourne du JSON { "base64": "..." } au lieu de bytes
    // bruts, on détecte le préfixe '{' et on décode le base64.
    if (data.length > 2 && data[0] == 0x7B /* '{' */) {
      try {
        final jsonStr = utf8.decode(data);
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        if (map.containsKey('base64')) {
          return base64Decode(map['base64'] as String);
        }
      } on Object {
        // Ce n'est pas du JSON valide → on retourne les bytes tels quels.
      }
    }
    return data;
  }

  Map<String, dynamic> _map(dynamic value) => value is Map
      ? Map<String, dynamic>.from(value)
      : const <String, dynamic>{};

  List<Map<String, dynamic>> _list(dynamic value) => value is List
      ? value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false)
      : const <Map<String, dynamic>>[];

  Map<String, dynamic>? _optionalParameter(
    String key,
    String? value, {
    bool omitEmpty = false,
  }) => value == null || (omitEmpty && value.isEmpty)
      ? null
      : <String, dynamic>{key: value};
}
