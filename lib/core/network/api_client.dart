import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../constants/app_environment.dart';
import '../error/exceptions.dart';
import 'api_response.dart';

/// Dio wrapper that returns the envelope's `data` and throws [AppException]s
/// carrying the backend's own error `code`.
///
/// Data sources depend on this, never on Dio directly.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  static Dio createDio({List<Interceptor> interceptors = const []}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppEnvironment.apiBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        // The two pre-order endpoints call AliExpress live, so they are
        // seconds rather than milliseconds — see [AppConstants].
        receiveTimeout: AppConstants.receiveTimeout,
        headers: const {'Accept': 'application/json'},
        responseType: ResponseType.json,
      ),
    );
    dio.interceptors.addAll(interceptors);
    return dio;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) => _request(
    () => _dio.get<dynamic>(
      path,
      // The API rejects unknown query params, so nulls are stripped rather
      // than sent as empty values.
      queryParameters: _clean(queryParameters),
      cancelToken: cancelToken,
    ),
  );

  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Duration? receiveTimeout,
  }) => _request(
    () => _dio.post<dynamic>(
      path,
      data: data,
      queryParameters: _clean(queryParameters),
      cancelToken: cancelToken,
      options: receiveTimeout == null
          ? null
          : Options(receiveTimeout: receiveTimeout),
    ),
  );

  Future<dynamic> put(String path, {Object? data, CancelToken? cancelToken}) =>
      _request(
        () => _dio.put<dynamic>(path, data: data, cancelToken: cancelToken),
      );

  Future<dynamic> patch(
    String path, {
    Object? data,
    CancelToken? cancelToken,
  }) => _request(
    () => _dio.patch<dynamic>(path, data: data, cancelToken: cancelToken),
  );

  Future<dynamic> delete(
    String path, {
    Object? data,
    CancelToken? cancelToken,
  }) => _request(
    () => _dio.delete<dynamic>(path, data: data, cancelToken: cancelToken),
  );

  Map<String, dynamic>? _clean(Map<String, dynamic>? params) {
    if (params == null) return null;
    final cleaned = <String, dynamic>{
      for (final entry in params.entries)
        if (entry.value != null) entry.key: entry.value,
    };
    return cleaned.isEmpty ? null : cleaned;
  }

  Future<dynamic> _request(Future<Response<dynamic>> Function() send) async {
    try {
      final response = await send();
      return ApiEnvelope.unwrap(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  AppException _mapDioException(DioException e) {
    final body = e.response?.data;
    final status = e.response?.statusCode;
    final message = _extractMessage(body) ?? e.message ?? 'Unexpected error';
    final code = _extractString(body, 'code');
    final details = _extractMap(body, 'details');
    final errors = _extractErrors(body);

    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const TimeoutException(),
      DioExceptionType.connectionError => const NetworkException(),
      DioExceptionType.badResponse => switch (status) {
        400 => ValidationException(
          message,
          errors: errors,
          code: code,
          details: details,
        ),
        401 => UnauthorizedException(message),
        403 => ForbiddenException(message, code: code, details: details),
        404 => NotFoundException(message, code: code, details: details),
        409 => ConflictException(message, code: code, details: details),
        429 => RateLimitException(message, code: code, details: details),
        503 => ServiceUnavailableException(
          message,
          code: code,
          details: details,
        ),
        _ => ServerException(
          message,
          statusCode: status,
          code: code,
          details: details,
        ),
      },
      DioExceptionType.cancel => const NetworkException('Request cancelled'),
      _ => ServerException(
        message,
        statusCode: status,
        code: code,
        details: details,
      ),
    };
  }

  String? _extractMessage(dynamic data) =>
      _extractString(data, 'message') ?? _extractString(data, 'error');

  String? _extractString(dynamic data, String key) {
    if (data is Map && data[key] is String) return data[key] as String;
    return null;
  }

  Map<String, dynamic>? _extractMap(dynamic data, String key) {
    if (data is Map && data[key] is Map) {
      return Map<String, dynamic>.from(data[key] as Map);
    }
    return null;
  }

  List<String> _extractErrors(dynamic data) {
    if (data is Map && data['errors'] is List) {
      return (data['errors'] as List).whereType<String>().toList();
    }
    return const [];
  }
}
