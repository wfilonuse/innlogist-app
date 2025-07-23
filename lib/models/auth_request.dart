class AuthRequest {
  final String email;
  final String password;
  final String timezone;
  final String locale;
  final String? gcmToken;

  AuthRequest({
    required this.email,
    required this.password,
    required this.timezone,
    required this.locale,
    this.gcmToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'timezone': timezone,
      'locale': locale,
      if (gcmToken != null) 'gcm_token': gcmToken,
    };
  }
}
