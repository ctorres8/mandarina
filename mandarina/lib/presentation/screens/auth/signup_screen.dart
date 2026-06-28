import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:mandarina/presentation/screens/auth/login_screen.dart';
import 'package:mandarina/presentation/viewmodel/auth_providers.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});
  static const name = "signup_screen";

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isPasswordConfirmVisible = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: MandarinaAppTheme.whiteColor,
          title: Text(
            '¡Cuenta registrada!',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              color: MandarinaAppTheme.accentColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Te hemos enviado un correo de verificación. Por favor, revisá tu casilla antes de ingresar.',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              color: MandarinaAppTheme.darkBlueColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MandarinaAppTheme.primaryColor,
                foregroundColor: MandarinaAppTheme.whiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
                context.goNamed(LoginScreen.name); // Redirige al Login
              },
              child: Text(
                'Cerrar',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: MandarinaAppTheme.primaryColor,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
            ),
            iconTheme: const IconThemeData(color: MandarinaAppTheme.whiteColor),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Bienvenido/a!',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 35,
                      color: MandarinaAppTheme.whiteColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Te pedimos un mail para registrarte.',
                    style: TextStyle(
                      fontSize: 18,
                      color: MandarinaAppTheme.whiteColor,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          cursorColor: MandarinaAppTheme.accentColor,
                          decoration: const InputDecoration(
                            hintText: 'Email',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor ingrese un email válido.';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          autocorrect: false,
                          cursorColor: MandarinaAppTheme.accentColor,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'Contraseña',
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: MandarinaAppTheme.accentColor,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese una contraseña.';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),
                        
                        TextFormField(
                          controller: _passwordConfirmController,
                          obscureText: !_isPasswordConfirmVisible,
                          autocorrect: false,
                          cursorColor: MandarinaAppTheme.accentColor,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'Confirmar Contraseña',
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isPasswordConfirmVisible = !_isPasswordConfirmVisible;
                                });
                              },
                              icon: Icon(
                                _isPasswordConfirmVisible ? Icons.visibility : Icons.visibility_off,
                                color: MandarinaAppTheme.accentColor,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese una contraseña.';
                            } else if (value != _passwordController.text) {
                              return 'Las contraseñas no coinciden.';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 30),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0.5,
                            backgroundColor: MandarinaAppTheme.secondaryColor,
                            foregroundColor: MandarinaAppTheme.accentColor,
                            disabledBackgroundColor: MandarinaAppTheme.secondaryColor.withValues(alpha: 0.8),
                            disabledForegroundColor: MandarinaAppTheme.accentColor,
                            minimumSize: const Size(double.infinity, 60),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    FocusManager.instance.primaryFocus?.unfocus();
                                    final success = await ref
                                        .read(authControllerProvider.notifier)
                                        .signUpWithEmail(
                                          _emailController.text,
                                          _passwordController.text,
                                        );
                                    if (success && context.mounted) {
                                      _showVerificationDialog();
                                    } else if (context.mounted) {
                                      final errorMsg = ref.read(authControllerProvider).errorMessage ?? 'Error de registro';
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            errorMsg,
                                            style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
                                          ),
                                          backgroundColor: MandarinaAppTheme.blueColor,
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: const Text(
                            'Registrarse',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0.5,
                            backgroundColor: MandarinaAppTheme.secondaryColor,
                            foregroundColor: MandarinaAppTheme.accentColor,
                            disabledBackgroundColor: MandarinaAppTheme.secondaryColor.withValues(alpha: 0.8),
                            disabledForegroundColor: MandarinaAppTheme.accentColor,
                            minimumSize: const Size(double.infinity, 60),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  final success = await ref.read(authControllerProvider.notifier).signInWithGoogle();
                                  if (!success && context.mounted) {
                                    final errorMsg = ref.read(authControllerProvider).errorMessage;
                                    if (errorMsg != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            errorMsg,
                                            style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
                                          ),
                                          backgroundColor: MandarinaAppTheme.blueColor,
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: const Text(
                            'Ingresar con Google',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        Center(child: Image.asset('assets/images/logo_blanco.png', scale: 3)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: true,
              child: Container(
                color: Colors.black.withValues(alpha: 0.45),
                child: Center(
                  child: Lottie.asset(
                    'assets/lotties/mandarina_loading.json',
                    width: 150,
                    height: 150,
                    repeat: true,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
