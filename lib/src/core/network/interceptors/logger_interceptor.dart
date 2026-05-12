import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

// Interceptor - 요청이 보내지기 전, 응답을 받았을 때, 또는 에러가 발생했을 때 Interceptor를 통해 가로채서 수정하거나 로그를 찍거나 처리할 수 있다.
class LoggerInterceptor extends Interceptor {
  LoggerInterceptor(
    this.logger, {
    // 출력 여부 설정 옵션
    this.request = true,
    this.requestHeader = true,
    this.requestBody = false,
    this.responseHeader = true,
    this.responseBody = false,
    this.error = true,
  });

  final Logger logger;

  /// Print request [Options]
  final bool request;

  /// Print request header [Options.headers]
  final bool requestHeader;

  /// Print request data [Options.data]
  final bool requestBody;

  /// Print [Response.data]
  final bool responseBody;

  /// Print [Response.headers]
  final bool responseHeader;

  /// Print error message
  final bool error;
  @override
  Future onRequest(RequestOptions options, handler) async {
    logPrint('*** Request ***');
    _printKV('uri', options.uri);

    if (request) {
      _printKV('method', options.method);
      _printKV('responseType', options.responseType.toString());
      _printKV('followRedirects', options.followRedirects);
      _printKV('connectTimeout', options.connectTimeout?.inSeconds ?? 0);
      _printKV('receiveTimeout', options.receiveTimeout?.inSeconds ?? 0);
      _printKV('extra', options.extra);
    }
    if (requestHeader) {
      logPrint('headers:');
      options.headers.forEach((key, v) => _printKV(' $key', v));
    }
    if (requestBody) {
      logPrint('data:');
      _printAll(options.data);
    }
    logPrint('');
    return super.onRequest(options, handler);
  }

  @override
  Future onError(DioException err, handler) async {
    if (error) {
      _printKVError("", '*** DioError ***:');
      _printKVError("", 'uri: ${err.requestOptions.uri}');
      _printKVError("", '$err');
      if (err.response != null) {
        _printResponse(err.response!);
      }
      logPrint('');
    }
    return super.onError(err, handler);
  }

  @override
  Future onResponse(Response response, handler) async {
    logPrint('*** Response ***');
    _printResponse(response);
    return super.onResponse(response, handler);
  }

  void _printResponse(Response response) {
    _printKV('uri', response.requestOptions.uri);
    if (responseHeader) {
      _printKV('statusCode', response.statusCode ?? 0);
      if (response.isRedirect == true) {
        _printKV('redirect', response.realUri);
      }
      logPrint('headers:');
      response.headers.forEach((key, v) => _printKV(' $key', v.join(',')));
    }
    if (responseBody) {
      logPrint('Response Text:');
      _printAll(response.toString());
    }
    logPrint('');
  }

  void _printKV(String key, Object v) {
    logPrint('$key: $v');
  }

  void _printKVError(String key, Object v) {
    logger.severe('$key: $v');
  }

  void _printAll(dynamic msg) {
    msg.toString().split('\n').forEach(logPrint);
  }

  void logPrint(String text) {
    logger.info(text);
  }
}
