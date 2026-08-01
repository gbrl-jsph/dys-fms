import 'package:dio/dio.dart';

/// Maps exceptions to a user-friendly error message (blueprint §4.4).
///
/// - Network failures → connection message
/// - API responses with a `message` → backend message
/// - 422 validation responses → first `errors` entry
/// - Anything else → generic fallback
String apiErrorMessage(Object error) {
  if (error is DioException) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Unable to connect to the server. Please try again.';
    }

    final response = error.response;
    if (response != null) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
        final errors = data['errors'];
        if (errors is Map<String, dynamic> && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty && first.first is String) {
            return first.first as String;
          }
        }
      }
    }
  }
  return 'Something went wrong. Please try again.';
}
