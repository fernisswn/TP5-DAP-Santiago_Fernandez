// Expone la sesión y las acciones de autenticación mediante Riverpod.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(firebaseAuthProvider).authStateChanges(),
);

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(
    ref.watch(firebaseAuthProvider),
    FirebaseFirestore.instance,
  );
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._auth, this._database) : super(const AsyncData(null));

  final FirebaseAuth _auth;
  final FirebaseFirestore _database;

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      state = const AsyncData(null);
    } on FirebaseAuthException catch (error, stackTrace) {
      state = AsyncError(authErrorMessage(error), stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      state = AsyncError('No se pudo iniciar sesión. Intentá nuevamente.', stackTrace);
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw StateError('Firebase no devolvió el usuario creado.');
      }

      await user.updateDisplayName(name.trim());
      await _database.collection('users').doc(user.uid).set({
        'displayName': name.trim(),
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await user.reload();
      state = const AsyncData(null);
    } on FirebaseAuthException catch (error, stackTrace) {
      state = AsyncError(authErrorMessage(error), stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      state = AsyncError(
        'La cuenta se creó, pero no se pudo guardar el perfil. Revisá la conexión e intentá nuevamente.',
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await _auth.signOut();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError('No se pudo cerrar sesión.', stackTrace);
      rethrow;
    }
  }
}

String authErrorMessage(FirebaseAuthException error) {
  switch (error.code) {
    case 'invalid-email':
      return 'El correo electrónico no tiene un formato válido.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'El correo o la contraseña son incorrectos.';
    case 'email-already-in-use':
      return 'Ya existe una cuenta registrada con ese correo.';
    case 'weak-password':
      return 'La contraseña debe tener al menos 6 caracteres.';
    case 'too-many-requests':
      return 'Hubo demasiados intentos. Esperá un momento y volvé a probar.';
    case 'network-request-failed':
      return 'No se pudo conectar. Revisá tu conexión a internet.';
    default:
      return 'Firebase no pudo completar la operación. Revisá los datos e intentá nuevamente.';
  }
}
