import 'package:flutter_test/flutter_test.dart';

import 'package:dys_fms/data/api/api_config.dart';

void main() {
  test('uses the API_BASE_URL environment value or production default', () {
    const String configuredBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://dys-fms.onrender.com/api',
    );

    expect(
      ApiConfig.baseUrl,
      configuredBaseUrl,
    );
  });

  test('derives the CSRF cookie URL from the API origin', () {
    final Uri apiUri = Uri.parse(ApiConfig.baseUrl);
    final Uri csrfUri = Uri.parse(ApiConfig.csrfCookieUrl);

    expect(csrfUri.scheme, apiUri.scheme);
    expect(csrfUri.authority, apiUri.authority);
    expect(csrfUri.path, '/sanctum/csrf-cookie');
    expect(csrfUri.hasQuery, isFalse);
  });
}
