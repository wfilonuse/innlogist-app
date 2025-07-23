class Constants {
  // Середовища
  static const String envDev = 'dev';
  static const String envStaging = 'staging';
  static const String envProduction = 'production';

  // Базові URL для різних середовищ
  static const Map<String, String> baseUrls = {
    envDev: 'https://dev.innlogist.com/api/v2',
    envStaging: 'https://staging.innlogist.com/api/v2',
    envProduction: 'https://api.innlogist.com/api/v2',
  };

  // Ключі для сервісів (Google Maps API Key)
  static const Map<String, String> serviceKeys = {
    envDev: 'YOUR_DEV_GOOGLE_MAPS_API_KEY',
    envStaging: 'YOUR_STAGING_GOOGLE_MAPS_API_KEY',
    envProduction: 'YOUR_PRODUCTION_GOOGLE_MAPS_API_KEY',
  };

  // Типи файлів для завантаження
  static const List<String> allowedFileTypes = [
    'image/jpeg',
    'image/png',
    'application/pdf',
  ];

  // Максимальний розмір файлу (5MB)
  static const int maxFileSize = 5 * 1024 * 1024;

  // Час виконання
  static const Duration locationTrackingInterval =
      Duration(seconds: 5); // Збір координат
  static const Duration syncInterval =
      Duration(minutes: 1); // Синхронізація геоточок
  static const double maxDeviationMeters = 100.0; // Максимальне відхилення
}
