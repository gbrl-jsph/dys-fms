import 'package:flutter_test/flutter_test.dart';

import 'package:dys_fms/features/auth/data/models/login_response.dart';

const Map<String, dynamic> userJson = <String, dynamic>{
  'id': 1,
  'name': 'Juan Dela Cruz',
  'email': 'owner@dys.com',
  'role': 'Business Owner',
  'sector_id': null,
  'account_status': 'Active',
};

void main() {
  test('parses a token when the native login response includes one', () {
    final LoginResponse response = LoginResponse.fromJson(<String, dynamic>{
      'data': <String, dynamic>{
        'user': userJson,
        'token': '1|native-token',
      },
    });

    expect(response.token, '1|native-token');
  });

  test('accepts a web session login response without a token', () {
    final LoginResponse response = LoginResponse.fromJson(<String, dynamic>{
      'data': <String, dynamic>{'user': userJson},
    });

    expect(response.token, isNull);
    expect(response.user.email, 'owner@dys.com');
  });
}
