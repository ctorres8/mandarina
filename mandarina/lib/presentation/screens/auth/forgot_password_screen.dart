import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:mandarina/presentation/viewmodel/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  static const name = 'forgot_password';

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showMyDialog() {
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
            '¡Mail enviado!',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              color: MandarinaAppTheme.accentColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Se ha enviado un enlace de restablecimiento a tu correo. Por favor, revisá tu casilla para cambiar la contraseña.',
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
                Navigator.pop(context); // Cierra el dialog
                context.pop(); // Vuelve al login
              },
              child: Text(
                'Entendido',
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
                    'Restablecer contraseña',
                    textAlign: TextAlign.left,
                    style: mandarinaTextStyle(
                      fontSize: 35,
                      color: MandarinaAppTheme.whiteColor,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Ingresa tu casilla de email debajo y te envíaremos un correo para restablecer tu contraseña.',
                    style: mandarinaTextStyle(
                      fontSize: 16,
                      color: MandarinaAppTheme.whiteColor,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.1,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Form(
                    key: _formKey,
                    child: TextFormField(
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
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0.5,
                      backgroundColor: MandarinaAppTheme.whiteBisColor,
                      foregroundColor: MandarinaAppTheme.primaryOrangeColor,
                      disabledBackgroundColor: MandarinaAppTheme.whiteBisColor
                          .withValues(alpha: 0.8),
                      disabledForegroundColor:
                          MandarinaAppTheme.primaryOrangeColor,
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
                                  .sendPasswordResetEmail(
                                    _emailController.text,
                                  );
                              if (success && context.mounted) {
                                _showMyDialog();
                              } else if (context.mounted) {
                                final errorMsg =
                                    ref
                                        .read(authControllerProvider)
                                        .errorMessage ??
                                    'Error al enviar correo';
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
                      'Enviar correo',
                      style: mandarinaTextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 150),

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
