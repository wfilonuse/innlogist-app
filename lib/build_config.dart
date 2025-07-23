import 'constants.dart';

class BuildConfig {
  static String environment = Constants.envDev;

  static void setEnvironment(String env) {
    if ([Constants.envDev, Constants.envStaging, Constants.envProduction]
        .contains(env)) {
      environment = env;
    } else {
      throw Exception('Invalid environment: $env');
    }
  }

  static String get baseUrl => Constants.baseUrls[environment]!;
  static String get googleMapsApiKey => Constants.serviceKeys[environment]!;
}
