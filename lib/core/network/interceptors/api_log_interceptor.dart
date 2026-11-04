import 'dart:convert';

import 'package:dio/dio.dart';

import '../../utils/app_logger.dart';

/// Colour-coded request/response logging, in place of `PrettyDioLogger`.
///
/// One block per request and one per answer — cyan going out, green coming
/// back, red when it fails — each fenced off by a rule, with the timing and
/// the status on the headline where the eye already is and the body indented
/// under it. The boxed output the app used to print buried the one thing
/// worth reading (which call, and did it work) inside a dozen lines of
/// borders; a single-line body hid it in the other direction, by running a
/// whole JSON payload off the right edge of the console.
///
/// Registered only when [AppEnvironment.enableLogging] is on, so nothing
/// here runs in a release build.
class ApiLogInterceptor extends Interceptor {
  /// Bodies longer than this are cut: a product list is thousands of
  /// characters and scrolls the useful lines off the screen.
  static const _maxBody = 1200;

  /// A cut by characters alone can still be forty lines of indented JSON.
  static const _maxLines = 30;

  static const _encoder = JsonEncoder.withIndent('  ');

  final _started = <RequestOptions, DateTime>{};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _started[options] = DateTime.now();

    AppLogger.group(
      '${AnsiColor.paint('→ ${options.method}', AnsiColor.cyan)} '
      '${options.uri}',
      lines: _body(options.data),
    );

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final status = response.statusCode ?? 0;
    final colour = status >= 200 && status < 300
        ? AnsiColor.green
        : AnsiColor.yellow;

    AppLogger.group(
      '${AnsiColor.paint('← $status', colour)} '
      '${response.requestOptions.method} ${response.requestOptions.uri} '
      '${AnsiColor.paint(_elapsed(response.requestOptions), AnsiColor.grey)}',
      lines: _body(response.data),
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;

    AppLogger.group(
      '${AnsiColor.paint('← ${status ?? err.type.name}', AnsiColor.red)} '
      '${err.requestOptions.method} ${err.requestOptions.uri} '
      '${AnsiColor.paint(_elapsed(err.requestOptions), AnsiColor.grey)}',
      lines: _body(err.response?.data),
      level: Level.warning,
    );

    handler.next(err);
  }

  String _elapsed(RequestOptions options) {
    final start = _started.remove(options);
    if (start == null) return '';
    return '${DateTime.now().difference(start).inMilliseconds}ms';
  }

  /// The payload as the lines that sit under the headline — empty for a call
  /// that carried none, so a GET stays a one-line block.
  List<String> _body(dynamic body) {
    if (body == null) return const [];

    final text = body is String ? body : _encode(body);
    if (text.trim().isEmpty) return const [];

    final truncated = text.length <= _maxBody
        ? text
        : '${text.substring(0, _maxBody)}… (${text.length} chars)';

    final lines = truncated.split('\n');
    if (lines.length <= _maxLines) return lines;
    return [
      ...lines.take(_maxLines),
      '… (${lines.length - _maxLines} more lines)',
    ];
  }

  String _encode(dynamic body) {
    try {
      return _encoder.convert(body);
    } on Object {
      return body.toString();
    }
  }
}
