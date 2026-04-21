# agenda

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase Auth - Google Login

This project now includes Google Sign-In integrated with Firebase Authentication.

### 1) Firebase Console

1. Open your Firebase project.
2. Go to **Authentication > Sign-in method**.
3. Enable the **Google** provider.

### 2) Android setup

1. Register your Android app in Firebase.
2. Add SHA-1 and SHA-256 fingerprints for your debug/release keystores.
3. Download and place `google-services.json` in `android/app/`.

### 3) iOS setup

1. Register your iOS app in Firebase.
2. Download and place `GoogleService-Info.plist` in `ios/Runner/`.
3. In Xcode, verify URL Types contains the **REVERSED_CLIENT_ID** as URL scheme.

### 4) Flutter dependencies

Run:

```bash
flutter pub get
```

### 5) Verify

Run the app and use **"Continuar con Google"** in the login screen.
