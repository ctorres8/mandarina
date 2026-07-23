import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:mandarina/presentation/screens/home_screen.dart';
import 'package:mandarina/presentation/viewmodel/auth_providers.dart';
import 'package:mandarina/presentation/widgets/tyc_bottomsheet.dart';
import 'package:mandarina/presentation/screens/auth/auth_tyc_helper.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});
  static const name = "signup_screen";

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isPasswordConfirmVisible = false;
  bool _termsAccepted = false;

  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = _showTermsBottomSheet;
    _privacyRecognizer = TapGestureRecognizer()..onTap = _showTermsBottomSheet;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _showTermsBottomSheet() {
    showTermsBottomSheet(
      context,
      onAccepted: () {
        setState(() {
          _termsAccepted = true;
        });
      },
    );
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
            'Te hemos enviado un correo de verificación. Por favor, revisá tu casilla.',
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
                ref.read(showSignupDialogProvider.notifier).state = false;
                Navigator.pop(context); // Cierra el diálogo
                context.goNamed(HomeScreen.name); // Redirige al Home
              },
              child: Text(
                'Aceptar',
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
                    style: mandarinaTextStyle(
                      fontSize: 35,
                      color: MandarinaAppTheme.whiteColor,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    'Te pedimos un mail para registrarte.',
                    style: mandarinaTextStyle(
                      fontSize: 18,
                      color: MandarinaAppTheme.whiteColor,
                      letterSpacing: -0.1,
                    ),
                  ),

                  const SizedBox(height: 30),

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
                          decoration: const InputDecoration(hintText: 'Email'),
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
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
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
                                  _isPasswordConfirmVisible =
                                      !_isPasswordConfirmVisible;
                                });
                              },
                              icon: Icon(
                                _isPasswordConfirmVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
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

                        const SizedBox(height: 20),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _termsAccepted,
                                activeColor: MandarinaAppTheme.whiteBisColor,
                                checkColor: MandarinaAppTheme.blueColor,
                                side: const BorderSide(
                                  color: MandarinaAppTheme.whiteColor,
                                  width: 2,
                                ),
                                onChanged: (bool? value) {
                                  setState(() {
                                    _termsAccepted = value ?? false;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.quicksand(
                                    color: MandarinaAppTheme.whiteColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Acepto los '),
                                    TextSpan(
                                      text: 'Términos y Condiciones',
                                      recognizer: _termsRecognizer,
                                      style: mandarinaTextStyle(
                                        color: MandarinaAppTheme.secondaryColor,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    const TextSpan(text: ' y la '),
                                    TextSpan(
                                      text: 'Política de Privacidad',
                                      recognizer: _privacyRecognizer,
                                      style: GoogleFonts.quicksand(
                                        color: MandarinaAppTheme.secondaryColor,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    const TextSpan(text: ' de Mandarina.'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0.5,
                            backgroundColor: MandarinaAppTheme.whiteBisColor,
                            foregroundColor:
                                MandarinaAppTheme.primaryOrangeColor,
                            disabledBackgroundColor: MandarinaAppTheme
                                .secondaryColor
                                .withValues(alpha: 0.4),
                            disabledForegroundColor:
                                MandarinaAppTheme.primaryOrangeColor,
                            minimumSize: const Size(double.infinity, 60),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: (isLoading || !_termsAccepted)
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    // Activar el flag para evitar redirección automática del router
                                    ref
                                            .read(
                                              showSignupDialogProvider.notifier,
                                            )
                                            .state =
                                        true;

                                    final success = await ref
                                        .read(authControllerProvider.notifier)
                                        .signUpWithEmail(
                                          _emailController.text,
                                          _passwordController.text,
                                        );
                                    if (success && context.mounted) {
                                      _showVerificationDialog();
                                    } else {
                                      // Desactivar el flag si falló la creación de cuenta e.g. error de red
                                      if (mounted) {
                                        ref
                                                .read(
                                                  showSignupDialogProvider
                                                      .notifier,
                                                )
                                                .state =
                                            false;
                                      }
                                      if (context.mounted) {
                                        final errorMsg =
                                            ref
                                                .read(authControllerProvider)
                                                .errorMessage ??
                                            'Error de registro';
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              errorMsg,
                                              style: GoogleFonts.quicksand(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            backgroundColor:
                                                MandarinaAppTheme.blueColor,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                          child: Text(
                            'Registrarse',
                            style: mandarinaTextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              height: 1,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0.5,
                            backgroundColor: MandarinaAppTheme.whiteBisColor,
                            foregroundColor:
                                MandarinaAppTheme.primaryOrangeColor,
                            disabledBackgroundColor: MandarinaAppTheme
                                .secondaryColor
                                .withValues(alpha: 0.4),
                            disabledForegroundColor:
                                MandarinaAppTheme.primaryOrangeColor,
                            minimumSize: const Size(double.infinity, 60),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: (isLoading || !_termsAccepted)
                              ? null
                              : () => handleGoogleAuthTermsFlow(
                                    context,
                                    ref,
                                    preAcceptedTerms: _termsAccepted,
                                  ),
                          child: Text(
                            'Ingresar con Google',
                            style: mandarinaTextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              height: 1,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Center(
                          child: Image.asset(
                            'assets/images/logo_blanco.png',
                            scale: 4,
                          ),
                        ),
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
