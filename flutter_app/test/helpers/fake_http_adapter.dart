import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Serves canned HTTP responses for the shared [ApiClient].
class FakeHttpClientAdapter implements HttpClientAdapter {
  Future<ResponseBody> Function(RequestOptions options) onRequest = (_) async =>
      jsonResponse(200, <String, dynamic>{});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return onRequest(options);
  }

  @override
  void close({bool force = false}) {}
}

/// JSON [ResponseBody] with the JSON content-type so Dio parses the data.
ResponseBody jsonResponse(int statusCode, Map<String, dynamic> data) {
  return ResponseBody.fromBytes(
    Uint8List.fromList(utf8.encode(jsonEncode(data))),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}
