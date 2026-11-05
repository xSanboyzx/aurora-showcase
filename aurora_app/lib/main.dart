import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// main.dart
/// Application entry: initializes Flutter bindings, Firebase (per-platform
/// options), local notification service, then boots the root `AuroraApp`.
/// AuroraApp sets up global theming (Material 3 + seeded color scheme) and
/// provides a transparent SnackBar theme since we use a custom overlay toast.
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'config/firebase_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/landing_screen.dart';
// import 'screens/auth/login_screen.dart'; // not needed when Landing is the unauthenticated start
import 'screens/aurora_shell.dart';
import 'services/auth_service.dart';
import 'services/notifications_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!FirebaseConfig.isConfigured) {
    runApp(const _SetupApp(
        message:
            'Firebase is not configured. Run the self-contained demo with: flutter run -t lib/main_demo.dart -d chrome. See README for your own Firebase or emulator setup.'));
    return;
  }
  try {
    await Firebase.initializeApp(options: FirebaseConfig.options);
    if (FirebaseConfig.useEmulators) {
      const host = String.fromEnvironment('FIREBASE_EMULATOR_HOST',
          defaultValue: '127.0.0.1');
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    }
  } catch (_) {
    runApp(const _SetupApp(
        message:
            'Aurora could not connect to the configured services. Check your Firebase configuration or start the emulators. The standalone demo works without a backend.'));
    return;
  }
  // Set Firebase Auth language for hosted messages (e.g., password reset emails)
  try {
    final deviceLang =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    await FirebaseAuth.instance.setLanguageCode(deviceLang);
  } catch (_) {/* ignore */}
  // Ask for permissions only from the explicit Settings action.
  if (!kIsWeb) {
    try {
      await NotificationService.instance.init();
    } catch (error) {
      debugPrint('Notifications unavailable: $error');
    }
  }
  runApp(const AuroraApp());
}

class AuroraApp extends StatelessWidget {
  const AuroraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aurora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF5C97B),
          brightness: Brightness.light,
        ),
        snackBarTheme: const SnackBarThemeData(
          elevation: 0,
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
      ),
      home: const _AuthGate(),
    );
  }
}

/// _AuthGate
/// Listens to auth state stream to route either authenticated dashboard or
/// unauthenticated landing screen. Centralizes logic so deep widgets don't
/// need to embed auth listeners.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading state while Firebase initializes/auth checks
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If signed in, show dashboard. If not, show landing page (user can proceed to login/signup).
        if (snapshot.hasData) {
          // Authenticated: show shell with bottom navigation across core areas.
          return const AuroraShell();
        }
        return const LandingScreen();
      },
    );
  }
}

class _SetupApp extends StatelessWidget {
  const _SetupApp({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => MaterialApp(
          home: Scaffold(
              body: Center(
        child: Padding(
            padding: const EdgeInsets.all(24), child: SelectableText(message)),
      )));
}
