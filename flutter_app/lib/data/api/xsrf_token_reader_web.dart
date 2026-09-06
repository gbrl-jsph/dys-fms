// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;

String? readXsrfToken() {
  for (final String cookie in html.document.cookie?.split(';') ?? const []) {
    final List<String> parts = cookie.trim().split('=');
    if (parts.length == 2 && parts.first == 'XSRF-TOKEN') {
      return Uri.decodeComponent(parts.last);
    }
  }
  return null;
}
