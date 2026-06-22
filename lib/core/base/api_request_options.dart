import 'package:dio/dio.dart';
import 'package:fclub/core/base/base_client.dart';

class ApiRequestOptions {
  const ApiRequestOptions._();

  static Options authorized() {
    return Options(headers: BaseClient.header, extra: {'authorized': true});
  }

  /// For bodyless requests (e.g. DELETE) — omits 'Content-Type' so an
  /// intermediary that strips the request body on these methods doesn't
  /// leave a stale 'application/json' header that makes the server expect
  /// JSON content that never arrives (triggers FST_ERR_CTP_EMPTY_JSON_BODY).
  static Options authorizedNoBody() {
    final headers = Map<String, String>.from(BaseClient.header)
      ..remove('Content-Type');
    return Options(headers: headers, extra: {'authorized': true});
  }
}
