import 'user_model.dart';

/// Successful `POST /api/login` response, parsed from the nested `data` object.
class LoginResponse {
  const LoginResponse({
    required this.user,
    required this.token,
    this.defaultSector,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = json['data'] as Map<String, dynamic>;
    final Map<String, dynamic>? defaultSector =
        data['default_sector'] as Map<String, dynamic>?;

    return LoginResponse(
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      token: data['token'] as String,
      defaultSector: defaultSector == null
          ? null
          : DefaultSector.fromJson(defaultSector),
    );
  }

  final UserModel user;
  final String token;
  final DefaultSector? defaultSector;
}

/// Initial sector context returned at login.
class DefaultSector {
  const DefaultSector({required this.id, required this.name});

  factory DefaultSector.fromJson(Map<String, dynamic> json) =>
      DefaultSector(id: json['id'] as int, name: json['name'] as String);

  final int id;
  final String name;
}
