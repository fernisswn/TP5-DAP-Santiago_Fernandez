// Dirige al ingreso o al catálogo según el estado de Firebase Authentication.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electrovault/presentation/providers/auth_provider.dart';
import 'package:electrovault/presentation/screens/components_screen.dart';
import 'package:electrovault/presentation/screens/login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(authStateProvider).when(
          data: (user) => user == null
              ? const LoginScreen()
              : ComponentsScreen(user: user),
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('No se pudo comprobar la sesión: $error'),
              ),
            ),
          ),
        );
  }
}
