import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:dys_fms/core/theme/app_theme.dart';
import 'package:dys_fms/features/auth/data/models/user_model.dart';
import 'package:dys_fms/features/auth/presentation/providers/auth_provider.dart';
import 'package:dys_fms/features/users/data/models/save_user_request.dart';
import 'package:dys_fms/features/users/data/models/user_account.dart';
import 'package:dys_fms/features/users/presentation/providers/users_provider.dart';
import 'package:dys_fms/features/users/presentation/screens/users_screen.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_users_repository.dart';

void main() {
  late FakeAuthRepository fakeAuthRepository;
  late AuthProvider authProvider;
  late FakeUsersRepository fakeUsersRepository;
  late UsersProvider usersProvider;

  setUp(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    fakeAuthRepository = FakeAuthRepository();
    fakeAuthRepository.onIsAuthenticated = () async => true;
    fakeAuthRepository.onGetStoredUser = () async =>
        UserModel.fromJson(ownerUserJson);
    authProvider = AuthProvider(fakeAuthRepository);
    await authProvider.checkAuthStatus();

    fakeUsersRepository = FakeUsersRepository();
    fakeUsersRepository.onGetUsers = () async => buildUsersList();
    usersProvider = UsersProvider(fakeUsersRepository);
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<UsersProvider>.value(value: usersProvider),
        ],
        child: MaterialApp(theme: AppTheme.build(Brightness.light), home: const UsersScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders title, section labels, and the user list table', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('Manage Users'), findsOneWidget);
    expect(find.text('USER LIST'), findsOneWidget);
    expect(find.text('ADD / EDIT USER'), findsOneWidget);
    expect(find.text('Juan Dela Cruz'), findsOneWidget);
    expect(find.text('Maria Santos'), findsOneWidget);
    expect(find.text('Pedro Reyes'), findsOneWidget);
    expect(find.text('B&DYS'), findsOneWidget);
    expect(find.text('DYS Events'), findsOneWidget);
    expect(find.text('Active'), findsNWidgets(2));
    expect(find.text('Inactive'), findsOneWidget);
    expect(find.text('Add User'), findsOneWidget);
    expect(find.text('Generate Temporary Password'), findsOneWidget);
    expect(
      find.text(
        'Accounts are deactivated, not deleted. Only the Business Owner can manage users.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('tapping the Owner row does not open the edit form', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Juan Dela Cruz'));
    await tester.pumpAndSettle();

    expect(find.text('Generate Temporary Password'), findsOneWidget);
    expect(find.text('Deactivate'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField).at(0)).controller?.text,
      isEmpty,
    );
  });

  testWidgets('a name longer than 255 characters shows the ceiling error', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).at(0), 'x' * 256);
    await tester.enterText(find.byType(TextField).at(1), 'rosa@dys.com');
    await tester.tap(find.text('Save Account'));
    await tester.pumpAndSettle();

    expect(find.text('Name must not exceed 255 characters.'), findsOneWidget);
  });

  testWidgets('shows the empty state when no users exist', (
    WidgetTester tester,
  ) async {
    fakeUsersRepository.onGetUsers = () async => [];

    await pumpScreen(tester);

    expect(find.text('No records yet'), findsOneWidget);
  });

  testWidgets('shows the loading indicator while the user list loads', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final Completer<List<UserAccount>> completer =
        Completer<List<UserAccount>>();
    fakeUsersRepository.onGetUsers = () => completer.future;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<UsersProvider>.value(value: usersProvider),
        ],
        child: MaterialApp(theme: AppTheme.build(Brightness.light), home: const UsersScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('No records yet'), findsNothing);

    completer.complete(buildUsersList());
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Juan Dela Cruz'), findsOneWidget);
  });

  testWidgets('saving an empty form shows validation errors', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Save Account'));
    await tester.pumpAndSettle();

    expect(find.text('Name is required.'), findsOneWidget);
    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Role is required.'), findsOneWidget);
    expect(find.text('Sector is required.'), findsOneWidget);
  });

  testWidgets('invalid email shows a format error', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).at(0), 'Rosa Martinez');
    await tester.enterText(find.byType(TextField).at(1), 'not-an-email');
    await tester.tap(find.text('Save Account'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });

  testWidgets('duplicate email shows the uniqueness error on create', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).at(0), 'Rosa Martinez');
    await tester.enterText(find.byType(TextField).at(1), 'maria@dys.com');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Event Manager').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('B&DYS').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Account'));
    await tester.pumpAndSettle();

    expect(find.text('Email has already been taken.'), findsOneWidget);
  });

  testWidgets('editing a user keeps their own email allowed', (
    WidgetTester tester,
  ) async {
    SaveUserRequest? sentRequest;
    fakeUsersRepository.onUpdateUser = (id, request) async {
      sentRequest = request;
      return UserAccount(
        id: id,
        name: request.name,
        email: request.email,
        role: request.role,
        sectorId: request.sectorId,
        sectorName: 'B&DYS',
        accountStatus: 'Active',
      );
    };

    await pumpScreen(tester);

    await tester.tap(find.text('Maria Santos'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Account'));
    await tester.pumpAndSettle();

    expect(sentRequest?.email, 'maria@dys.com');
    expect(find.text('Email has already been taken.'), findsNothing);
    expect(find.text('User updated successfully.'), findsOneWidget);
  });

  testWidgets(
    'create flow submits the request and shows the temporary password',
    (WidgetTester tester) async {
      SaveUserRequest? sentRequest;
      fakeUsersRepository.onCreateUser = (request) async {
        sentRequest = request;
        return UserAccount(
          id: 4,
          name: request.name,
          email: request.email,
          role: request.role,
          sectorId: request.sectorId,
          sectorName: 'B&DYS',
          accountStatus: 'Active',
          temporaryPassword: 'Temp@12345',
          passwordSent: true,
        );
      };

      await pumpScreen(tester);

      await tester.enterText(find.byType(TextField).at(0), 'Rosa Martinez');
      await tester.enterText(find.byType(TextField).at(1), 'rosa@dys.com');

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Event Manager').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('B&DYS').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Account'));
      await tester.pumpAndSettle();

      expect(sentRequest?.name, 'Rosa Martinez');
      expect(sentRequest?.email, 'rosa@dys.com');
      expect(sentRequest?.role, 'Event Manager');
      expect(sentRequest?.sectorId, 2);
      expect(
        find.text(
          'Temporary password generated successfully. A copy has also '
          "been sent to the user's email. Temporary password: Temp@12345",
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'generate temporary password button also submits the create flow',
    (WidgetTester tester) async {
      bool createCalled = false;
      fakeUsersRepository.onCreateUser = (request) async {
        createCalled = true;
        return UserAccount(
          id: 4,
          name: request.name,
          email: request.email,
          role: request.role,
          sectorId: request.sectorId,
          sectorName: 'B&DYS',
          accountStatus: 'Active',
          temporaryPassword: 'Gen@12345',
          passwordSent: true,
        );
      };

      await pumpScreen(tester);

      await tester.enterText(find.byType(TextField).at(0), 'Rosa Martinez');
      await tester.enterText(find.byType(TextField).at(1), 'rosa@dys.com');
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Event Manager').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('B&DYS').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Generate Temporary Password'));
      await tester.pumpAndSettle();

      expect(createCalled, isTrue);
      expect(
        find.text(
          'Temporary password generated successfully. A copy has also '
          "been sent to the user's email. Temporary password: Gen@12345",
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('create flow warns when the temporary password email fails', (
    WidgetTester tester,
  ) async {
    fakeUsersRepository.onCreateUser = (request) async {
      return UserAccount(
        id: 4,
        name: request.name,
        email: request.email,
        role: request.role,
        sectorId: request.sectorId,
        sectorName: 'B&DYS',
        accountStatus: 'Active',
        temporaryPassword: 'Fail@12345',
        passwordSent: false,
      );
    };

    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).at(0), 'Rosa Martinez');
    await tester.enterText(find.byType(TextField).at(1), 'rosa@dys.com');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Event Manager').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('B&DYS').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Account'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Temporary password generated successfully. The email could not '
        'be delivered. Please provide the temporary password manually. '
        'Temporary password: Fail@12345',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'tapping a row populates the form for editing and updates the user',
    (WidgetTester tester) async {
      SaveUserRequest? sentRequest;
      int? updatedId;
      fakeUsersRepository.onUpdateUser = (id, request) async {
        updatedId = id;
        sentRequest = request;
        return UserAccount(
          id: id,
          name: request.name,
          email: request.email,
          role: request.role,
          sectorId: request.sectorId,
          sectorName: 'B&DYS',
          accountStatus: 'Active',
        );
      };

      await pumpScreen(tester);

      await tester.tap(find.text('Maria Santos'));
      await tester.pumpAndSettle();

      expect(find.text('Maria Santos'), findsNWidgets(2));

      await tester.enterText(
        find.byType(TextField).at(0),
        'Maria Santos Updated',
      );
      await tester.tap(find.text('Save Account'));
      await tester.pumpAndSettle();

      expect(updatedId, 2);
      expect(sentRequest?.name, 'Maria Santos Updated');
      expect(find.text('User updated successfully.'), findsOneWidget);
      expect(find.text('Generate Temporary Password'), findsNothing);
    },
  );

  testWidgets('deactivate button sends Inactive for an active user', (
    WidgetTester tester,
  ) async {
    String? updatedStatus;
    int? updatedId;
    fakeUsersRepository.onUpdateUserStatus = (id, accountStatus) async {
      updatedId = id;
      updatedStatus = accountStatus;
      return UserAccount(
        id: id,
        name: 'Maria Santos',
        email: 'maria@dys.com',
        role: 'Event Manager',
        sectorId: 2,
        sectorName: 'B&DYS',
        accountStatus: accountStatus,
      );
    };

    await pumpScreen(tester);

    await tester.tap(find.text('Maria Santos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deactivate'));
    await tester.pumpAndSettle();

    expect(updatedId, 2);
    expect(updatedStatus, 'Inactive');
    expect(find.text('User status updated successfully.'), findsOneWidget);
  });

  testWidgets('activate button sends Active for an inactive user', (
    WidgetTester tester,
  ) async {
    String? updatedStatus;
    fakeUsersRepository.onUpdateUserStatus = (id, accountStatus) async {
      updatedStatus = accountStatus;
      return UserAccount(
        id: id,
        name: 'Pedro Reyes',
        email: 'pedro@dys.com',
        role: 'Employee/Staff',
        sectorId: 1,
        sectorName: 'DYS Events',
        accountStatus: accountStatus,
      );
    };

    await pumpScreen(tester);

    await tester.tap(find.text('Pedro Reyes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Activate'));
    await tester.pumpAndSettle();

    expect(updatedStatus, 'Active');
  });

  testWidgets('reset temporary password button submits the reset flow', (
    WidgetTester tester,
  ) async {
    int? resetId;
    fakeUsersRepository.onResetPassword = (id) async {
      resetId = id;
      return UserAccount(
        id: id,
        name: 'Maria Santos',
        email: 'maria@dys.com',
        role: 'Event Manager',
        sectorId: 2,
        sectorName: 'B&DYS',
        accountStatus: 'Active',
        temporaryPassword: 'New@12345',
        passwordSent: true,
      );
    };

    await pumpScreen(tester);

    await tester.tap(find.text('Maria Santos'));
    await tester.pumpAndSettle();

    expect(find.text('Reset Temporary Password'), findsOneWidget);

    await tester.tap(find.text('Reset Temporary Password'));
    await tester.pumpAndSettle();

    expect(resetId, 2);
    expect(
      find.text(
        'Temporary password reset successfully. New password '
        'emailed to maria@dys.com. Temporary password: New@12345',
      ),
      findsOneWidget,
    );
  });

  testWidgets('add user resets the form from edit mode', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Maria Santos'));
    await tester.pumpAndSettle();
    expect(find.text('Deactivate'), findsOneWidget);

    await tester.tap(find.text('Add User'));
    await tester.pumpAndSettle();

    expect(find.text('Deactivate'), findsNothing);
    expect(find.text('Generate Temporary Password'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).at(0)).controller?.text,
      isEmpty,
    );
  });

  testWidgets('backend error is displayed in the error container', (
    WidgetTester tester,
  ) async {
    fakeUsersRepository.onCreateUser = (_) async {
      throw Exception('Forbidden.');
    };

    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).at(0), 'Rosa Martinez');
    await tester.enterText(find.byType(TextField).at(1), 'rosa@dys.com');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Event Manager').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('B&DYS').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Account'));
    await tester.pumpAndSettle();

    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });
}
