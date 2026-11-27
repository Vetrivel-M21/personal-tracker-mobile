# Aura Mobile App (Flutter)

Aura Fitness Challenge & Personal Tracker mobile client built with Flutter, Riverpod, and Dio.

## Development & Networking

By default, the app points to `https://api.aura.app` in production. For local development, cleartext traffic is permitted via the debug network security configuration (`android/app/src/debug/res/xml/network_security_config.xml`).

### Running Locally

To run the app pointing to your local development backend:

#### Android Emulator (pointing to host machine):
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

#### Physical Device (LAN IP of host machine):
```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8080
```

#### Windows / Web / Desktop:
```bash
flutter run -d windows --dart-define=API_BASE_URL=http://localhost:8080
```

## Release Signing Configuration

The Android build configuration supports custom release signing via `android/key.properties`. This file is git-ignored and should not be checked into version control.

To configure release signing:
1. Generate your release keystore:
   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Create `android/key.properties` with the following content:
   ```properties
   storePassword=your_store_password
   keyPassword=your_key_password
   keyAlias=upload
   storeFile=../app/upload-keystore.jks
   ```
3. Build the release APK or app bundle:
   ```bash
   flutter build apk --release
   # or
   flutter build appbundle --release
   ```

If `android/key.properties` is missing, the release build automatically falls back to debug signing to facilitate local release testing.
