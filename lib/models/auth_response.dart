import 'driver.dart';
import 'transport.dart';

class AuthResponse {
  final String token;
  final Driver driver;
  final Transport transport;
  final String lang;
  final int expiresIn;

  AuthResponse({
    required this.token,
    required this.driver,
    required this.transport,
    required this.lang,
    required this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String? ?? '',
      driver: Driver.fromJson(json['driver'] as Map<String, dynamic>? ?? {}),
      transport:
          Transport.fromJson(json['transport'] as Map<String, dynamic>? ?? {}),
      lang: json['lang'] as String? ?? 'ua',
      expiresIn: json['expires_in'] as int? ?? 28800,
    );
  }
}
