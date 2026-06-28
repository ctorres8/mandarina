import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream de cambios de estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // Registrarse con email y contraseña
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      // Enviar mail de verificación
      await credential.user?.sendEmailVerification();

      // Cerrar sesión inmediatamente para que no se redirija automáticamente
      await _auth.signOut();

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Ha ocurrido un error inesperado al registrarse.');
    }
  }

  // Iniciar sesión con email y contraseña
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Si el correo no está verificado, forzar cierre de sesión y lanzar error
      if (credential.user != null && !credential.user!.emailVerified) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Por favor, verifica tu correo electrónico antes de ingresar. Revisa tu casilla.',
        );
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Ha ocurrido un error inesperado al iniciar sesión.');
    }
  }

  // Iniciar sesión interactivo con Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Cancelado por el usuario
        return null;
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Ha ocurrido un error inesperado al iniciar sesión con Google.');
    }
  }

  // Enviar email para restablecer contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Ha ocurrido un error inesperado al enviar el correo de recuperación.');
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Error al cerrar sesión.');
    }
  }

  // Traducción exhaustiva de excepciones de Firebase a español
  Exception _handleAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'invalid-email':
        message = 'El correo electrónico ingresado no es válido.';
        break;
      case 'user-disabled':
        message = 'Esta cuenta de usuario ha sido deshabilitada.';
        break;
      case 'user-not-found':
        message = 'No se encontró ninguna cuenta con este correo electrónico.';
        break;
      case 'wrong-password':
        message = 'La contraseña ingresada es incorrecta.';
        break;
      case 'email-already-in-use':
        message = 'El correo electrónico ya se encuentra registrado.';
        break;
      case 'weak-password':
        message = 'La contraseña ingresada es demasiado débil. Debe tener al menos 6 caracteres.';
        break;
      case 'operation-not-allowed':
        message = 'El método de autenticación seleccionado no está habilitado.';
        break;
      case 'invalid-credential':
        message = 'Las credenciales proporcionadas no son válidas o han expirado.';
        break;
      case 'network-request-failed':
        message = 'Error de conexión. Por favor, comprueba tu conexión a internet.';
        break;
      case 'too-many-requests':
        message = 'Demasiados intentos fallidos. Inténtalo de nuevo en unos minutos.';
        break;
      case 'email-not-verified':
        message = 'Por favor, verifica tu correo electrónico antes de ingresar. Revisa tu casilla.';
        break;
      case 'account-exists-with-different-credential':
        message = 'Ya existe una cuenta con el mismo correo electrónico pero diferentes credenciales.';
        break;
      default:
        message = e.message ?? 'Ocurrió un error en la autenticación.';
    }
    return Exception(message);
  }
}
