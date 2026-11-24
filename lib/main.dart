// Inicia Firebase y muestra la pantalla correspondiente a la sesión.
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electrovault/core/app_theme.dart';
import 'package:electrovault/firebase_options.dart';
import 'package:electrovault/presentation/screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? firebaseError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (const bool.fromEnvironment('USE_FIREBASE_EMULATORS')) {
      final emulatorHost = kIsWeb ? '127.0.0.1' : '10.0.2.2';
      await FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);
      FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8080);
    }
  } catch (error) {
    firebaseError = error;
  }

  runApp(
    ProviderScope(
      child: ElectroVaultApp(firebaseError: firebaseError),
    ),
  );
}

class ElectroVaultApp extends StatelessWidget {
  const ElectroVaultApp({super.key, this.firebaseError});

  final Object? firebaseError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ElectroVault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: firebaseError == null
          ? const AuthGate()
          : FirebaseSetupScreen(error: firebaseError!),
    );
  }
}

class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔌', style: TextStyle(fontSize: 54)),
                const SizedBox(height: 20),
                Text(
                  'Falta conectar Firebase',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Revisá la configuración Firebase generada para esta plataforma y volvé a iniciar la aplicación.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
