import 'package:firebase_core/firebase_core.dart';

/// Supply your own project's public client configuration at build time.
/// This fork never falls back to the original team's Firebase project.
class FirebaseConfig {
  static const useEmulators = bool.fromEnvironment('USE_FIREBASE_EMULATORS');
  static const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const appId = String.fromEnvironment('FIREBASE_APP_ID');
  static bool get isConfigured =>
      useEmulators ||
      (projectId.isNotEmpty && apiKey.isNotEmpty && appId.isNotEmpty);

  static FirebaseOptions get options => const FirebaseOptions(
        apiKey: useEmulators ? 'demo-key' : apiKey,
        appId: useEmulators ? '1:123456789:web:aurora' : appId,
        messagingSenderId: String.fromEnvironment(
            'FIREBASE_MESSAGING_SENDER_ID',
            defaultValue: '123456789'),
        projectId: useEmulators ? 'demo-aurora' : projectId,
        authDomain: useEmulators
            ? 'demo-aurora.firebaseapp.com'
            : String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
      );
}
