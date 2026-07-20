import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:mandarina/presentation/screens/auth/forgot_password_screen.dart';
import 'package:mandarina/presentation/viewmodel/auth_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mandarina/data/repositories/user_repository.dart';
import 'package:mandarina/presentation/widgets/tyc_bottomsheet.dart';
import 'package:mandarina/presentation/screens/home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  static const name = 'login_screen';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                    '¡Hola de nuevo!',
                    textAlign: TextAlign.left,
                    style: mandarinaTextStyle(
                      fontSize: 35,
                      color: MandarinaAppTheme.whiteColor,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    'Estamos contentos de verte otra vez.',
                    style: mandarinaTextStyle(
                      fontSize: 18,
                      color: MandarinaAppTheme.whiteColor,
                      letterSpacing: -0.1,
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
                          style: mandarinaTextStyle(
                            color: MandarinaAppTheme.accentColor,
                            fontWeight: FontWeight.w700,
                          ),
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
                          style: mandarinaTextStyle(
                            color: MandarinaAppTheme.accentColor,
                            fontWeight: FontWeight.w700,
                          ),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              context.pushNamed(ForgotPasswordScreen.name);
                            },
                      child: Text(
                        'Olvidé mi contraseña',
                        style: mandarinaTextStyle(
                          color: MandarinaAppTheme.whiteColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          decoration: TextDecoration.underline,
                          decorationColor: MandarinaAppTheme.whiteColor,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0.5,
                      backgroundColor: MandarinaAppTheme.whiteBisColor,
                      foregroundColor: MandarinaAppTheme.primaryOrangeColor,
                      disabledBackgroundColor: MandarinaAppTheme.secondaryColor
                          .withValues(alpha: 0.8),
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
                                  .signInWithEmail(
                                    _emailController.text,
                                    _passwordController.text,
                                  );
                              if (!success && context.mounted) {
                                final errorMsg =
                                    ref
                                        .read(authControllerProvider)
                                        .errorMessage ??
                                    'Error de inicio de sesión';
                                ScaffoldMessenger.of(context).showSnackBar(
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
                          },
                    child: Text(
                      'Ingresar',
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
                      foregroundColor: MandarinaAppTheme.primaryOrangeColor,
                      disabledBackgroundColor: MandarinaAppTheme.secondaryColor
                          .withValues(alpha: 0.8),
                      disabledForegroundColor: MandarinaAppTheme.accentColor,
                      minimumSize: const Size(double.infinity, 60),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            ref.read(preventRedirectProvider.notifier).state =
                                true;
                            final success = await ref
                                .read(authControllerProvider.notifier)
                                .signInWithGoogle();
                            if (success && context.mounted) {
                              final user = ref
                                  .read(firebaseAuthServiceProvider)
                                  .currentUser;
                              if (user != null) {
                                final userRepository = ref.read(
                                  userRepositoryProvider,
                                );
                                final doc = await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .get();
                                final bool hasAccepted =
                                    doc.exists &&
                                    (doc.data()?['acceptedTerms'] == true);

                                if (hasAccepted) {
                                  ref
                                          .read(
                                            preventRedirectProvider.notifier,
                                          )
                                          .state =
                                      false;
                                } else {
                                  bool accepted = false;
                                  if (context.mounted) {
                                    await showTermsBottomSheet(
                                      context,
                                      onAccepted: () {
                                        accepted = true;
                                      },
                                    );
                                  }
                                  if (accepted) {
                                    await userRepository
                                        .createUserProfileAfterSignup(
                                          user.uid,
                                          user.email ?? '',
                                        );
                                    ref
                                            .read(
                                              preventRedirectProvider.notifier,
                                            )
                                            .state =
                                        false;
                                    if (context.mounted) {
                                      context.goNamed(HomeScreen.name);
                                    }
                                  } else {
                                    await ref
                                        .read(authControllerProvider.notifier)
                                        .signOut();
                                    ref
                                            .read(
                                              preventRedirectProvider.notifier,
                                            )
                                            .state =
                                        false;
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Debes aceptar los Términos y Condiciones para ingresar.',
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
                              } else {
                                ref
                                        .read(preventRedirectProvider.notifier)
                                        .state =
                                    false;
                              }
                            } else {
                              ref.read(preventRedirectProvider.notifier).state =
                                  false;
                              if (context.mounted) {
                                final errorMsg = ref
                                    .read(authControllerProvider)
                                    .errorMessage;
                                if (errorMsg != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
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
                      'Ingresar con Google',
                      style: mandarinaTextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 70),

                  Center(
                    child: Image.asset(
                      'assets/images/logo_blanco.png',
                      scale: 4,
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
