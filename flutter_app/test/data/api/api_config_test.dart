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

  test('uses the origin root for the CSRF cookie URL', () {
    final Uri apiUri = Uri.parse(ApiConfig.baseUrl);
    final Uri csrfUri = Uri.parse(ApiConfig.csrfCookieUrl);

    if (apiUri.hasScheme) {
      expect(csrfUri.scheme, apiUri.scheme);
      expect(csrfUri.authority, apiUri.authority);
    } else {
      expect(csrfUri.isAbsolute, isTrue);
    }
    expect(csrfUri.path, '/sanctum/csrf-cookie');
    expect(csrfUri.path, isNot('/api/sanctum/csrf-cookie'));
    expect(csrfUri.hasQuery, isFalse);
  });
}
