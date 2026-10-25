import 'package:dio/dio.dart';

/// Retries transient failures of idempotent requests with a short back-off.
class ErrorInterceptor extends Interceptor {
  final Dio _dio;
  static const _maxRetries = 2;
  static const _retryKey = 'retry_count';
  static const _idempotent = {'GET', 'HEAD', 'OPTIONS', 'PUT', 'DELETE'};

  ErrorInterceptor(this._dio);

  bool _isTransient(DioException err) =>
      err.type == DioExceptionType.connectionTimeout ||
      err.type == DioExceptionType.receiveTimeout ||
      err.type == DioExceptionType.connectionError ||
      (err.response?.statusCode ?? 0) >= 500;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final attempt = (options.extra[_retryKey] as int?) ?? 0;

    // Only retry once per failed call: the retried request carries its attempt
    // count, so it cannot fan out through this interceptor again.
    if (!_idempotent.contains(options.method.toUpperCase()) ||
        !_isTransient(err) ||
        attempt >= _maxRetries) {
      return handler.next(err);
    }

    await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
    options.extra[_retryKey] = attempt + 1;
    try {
      return handler.resolve(await _dio.fetch(options));
    } on DioException catch (e) {
      return handler.next(e);
    }
  }
}
