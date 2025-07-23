# inn_logist_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Для Android (android/app/src/main/AndroidManifest.xml):
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

Для iOS (ios/Runner/Info.plist):
<key>NSLocationWhenInUseUsageDescription</key>
<string>Дозвольте доступ до геолокації для відстеження маршруту</string>

# Для dev
flutter build apk --dart-define=ENVIRONMENT=dev

# Для staging
flutter build apk --dart-define=ENVIRONMENT=staging

# Для production
flutter build apk --dart-define=ENVIRONMENT=production
