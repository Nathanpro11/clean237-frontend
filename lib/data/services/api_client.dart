import 'dart:convert';

import 'package:dio/dio.dart';

import '../exceptions/app_exception.dart';
import '../../utils/constances/api_constants.dart';

class ApiClient {
  ApiClient({
    Dio? dio,
    Future<String?> Function()? tokenProvider,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: ApiConstants.connectTimeout,
                receiveTimeout: ApiConstants.receiveTimeout,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    if (tokenProvider != null) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            try {
              final token = await tokenProvider();
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            } catch (_) {}
            handler.next(options);
          },
        ),
      );
    }
  }

  final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(
      _dio.get<T>(path, queryParameters: queryParameters),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(
      _dio.post<T>(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(
      _dio.delete<T>(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(
      _dio.patch<T>(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<Response<List<int>>> getBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(
      _dio.get<List<int>>(
        path,
        queryParameters: queryParameters,
        options: Options(
          responseType: ResponseType.bytes,
          headers: <String, dynamic>{
            'Accept': '*/*',
          },
        ),
      ),
    );
  }

  Future<Response<T>> _request<T>(Future<Response<T>> request) async {
    try {
      return await request;
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  AppException _mapError(DioException error) {
    // --- Priorité 1 : si une réponse HTTP existe, utiliser le statut. ---
    final statusCode = error.response?.statusCode;
    if (statusCode != null) {
      final backendMessage = _extractMessage(error.response?.data);
      switch (statusCode) {
        case 400:
          return ValidationException(backendMessage, statusCode: 400);
        case 404:
          return NotFoundException(backendMessage);
        case 409:
          return ConflictException(backendMessage);
        case 422:
          return ValidationException(backendMessage, statusCode: 422);
        case 500:
        case 501:
        case 502:
        case 503:
        case 504:
          final message = backendMessage == 'Une erreur est survenue.'
              ? 'Erreur du serveur lors de la génération du fichier. Réessayez.'
              : backendMessage;
          return ServerException(message, statusCode: statusCode);
        default:
          if (statusCode >= 400 && statusCode < 500) {
            return ValidationException(
              backendMessage,
              statusCode: statusCode,
            );
          }
          if (statusCode >= 500) {
            final message = backendMessage == 'Une erreur est survenue.'
                ? 'Erreur du serveur lors de la génération du fichier. Réessayez.'
                : backendMessage;
            return ServerException(message, statusCode: statusCode);
          }
      }
    }

    // --- Priorité 2 : aucune réponse → erreur réseau pure. ---
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException(
          'Impossible de joindre le serveur. Vérifiez votre connexion.',
        );
      case DioExceptionType.cancel:
        return const NetworkException('La requête a été annulée.');
      default:
        return const NetworkException(
          'Impossible de joindre le serveur. Vérifiez votre connexion.',
        );
    }
  }

  String _extractMessage(dynamic payload) {
    if (payload is List<int>) {
      try {
        payload = jsonDecode(utf8.decode(payload));
      } on FormatException {
        return 'Une erreur est survenue.';
      }
    }
    if (payload is String) {
      try {
        payload = jsonDecode(payload);
      } on FormatException {
        return payload.isNotEmpty ? payload : 'Une erreur est survenue.';
      }
    }
    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);
      final message = map['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
      final error = map['error'];
      if (error is String && error.trim().isNotEmpty) {
        return error;
      }
    }
    return 'Une erreur est survenue.';
  }
}
