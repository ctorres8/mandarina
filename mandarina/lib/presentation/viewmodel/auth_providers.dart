import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mandarina/services/firebase_auth_service.dart';

// Provider para la instancia de FirebaseAuthService
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

// StreamProvider que escucha los cambios de estado de Firebase Auth
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return authService.authStateChanges;
});

// Provider para controlar si se está mostrando el diálogo de verificación en Signup
final showSignupDialogProvider = StateProvider<bool>((ref) {
  return false;
});

// Clase de estado para manejar la UI de Login/Registro
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  AuthState copyWith({bool? isLoading, String? errorMessage, bool? isSuccess}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          errorMessage, // Resetea el error si no se pasa explícitamente
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// Controller para manejar los estados de la UI durante llamadas asíncronas usando Notifier
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState();
  }

  // Iniciar sesión con Email
  Future<bool> signInWithEmail(String email, String password) async {
    state = AuthState(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      await authService.signInWithEmail(email, password);
      state = AuthState(isSuccess: true);
      return true;
    } catch (e) {
      state = AuthState(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // Registrarse con Email
  Future<bool> signUpWithEmail(String email, String password) async {
    state = AuthState(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      await authService.signUpWithEmail(email, password);
      state = AuthState(isSuccess: true);
      return true;
    } catch (e) {
      state = AuthState(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // Iniciar sesión con Google
  Future<bool> signInWithGoogle() async {
    state = AuthState(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      final userCred = await authService.signInWithGoogle();
      if (userCred != null) {
        state = AuthState(isSuccess: true);
        return true;
      } else {
        // Cancelado por el usuario
        state = AuthState();
        return false;
      }
    } catch (e) {
      state = AuthState(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // Enviar correo de restablecimiento de contraseña
  Future<bool> sendPasswordResetEmail(String email) async {
    state = AuthState(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      await authService.sendPasswordResetEmail(email);
      state = AuthState(isSuccess: true);
      return true;
    } catch (e) {
      state = AuthState(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    state = AuthState(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      await authService.signOut();
      state = AuthState(isSuccess: true);
    } catch (e) {
      state = AuthState(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // Limpiar mensaje de error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Provider de nuestro Notifier para la UI
final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
