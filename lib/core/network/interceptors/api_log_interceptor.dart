import 'package:dio/dio.dart';

import '../../utils/app_logger.dart';

/// Debug request timing without recording credentials or customer data.
///
/// Query strings, request/response bodies and headers can contain OTPs,
/// addresses, payment details or tokens. Even a debug console can be shared
/// or saved, so only method, path, status and elapsed time are logged.
class ApiLogInterceptor extends Interceptor {
  final _started = <RequestOptions, DateTime>{};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _started[options] = DateTime.now();
    AppLogger.i('→ ${options.method} ${options.uri.path}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final request = response.requestOptions;
    AppLogger.i(
      '← ${response.statusCode ?? 0} ${request.method} ${request.uri.path} '
      '${_elapsed(request)}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final request = err.requestOptions;
    AppLogger.w(
      '← ${err.response?.statusCode ?? err.type.name} '
      '${request.method} ${request.uri.path} ${_elapsed(request)}',
    );
    handler.next(err);
  }

  String _elapsed(RequestOptions options) {
    final start = _started.remove(options);
    if (start == null) return '';
    return '${DateTime.now().difference(start).inMilliseconds}ms';
  }
}
