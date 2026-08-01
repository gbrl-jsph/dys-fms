import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dys_fms/app.dart';
import 'package:dys_fms/core/network/api_client.dart';
import 'package:dys_fms/core/storage/secure_storage.dart';
import 'package:dys_fms/features/auth/data/repositories/auth_repository.dart';
import 'package:dys_fms/features/auth/presentation/providers/auth_provider.dart';
import 'package:dys_fms/routing/app_router.dart';

void main() {
  testWidgets('App boots to the login screen', (WidgetTester tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    final SecureStorage secureStorage = SecureStorage();
    ApiClient.init(tokenProvider: secureStorage.getToken);
    final AuthProvider authProvider =
        AuthProvider(AuthRepository(ApiClient.instance, secureStorage));

    await tester.pumpWidget(
      App(
        authProvider: authProvider,
        router: AppRouter.create(authProvider),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('DYS Financial Management System (DYS FMS)'),
      findsOneWidget,
    );
    expect(find.text('Log In'), findsOneWidget);
  });
}
