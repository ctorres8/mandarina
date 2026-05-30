import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:mandarina/presentation/screens/auth/login_screen.dart';
import 'package:mandarina/presentation/screens/auth/signup_screen.dart';

class LandingScreen extends StatelessWidget {
  static const String name = 'landing_screen';
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _LandingScreenView();
  }
}

class _LandingScreenView extends StatelessWidget {
  const _LandingScreenView();

  @override
  Widget build(BuildContext context) {
    ///final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    return Scaffold(
      // Usamos el primaryColor que definiste en tu MandarinaAppTheme
      backgroundColor: MandarinaAppTheme.primaryColor,//colors.primary, 
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            Image.asset('assets/images/isologotipo.png',scale:1.8,),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                'Diseñada para tu ritmo, creada para tu concentración.',
                textAlign: TextAlign.center,
                style: textStyles.bodyLarge?.copyWith(color: MandarinaAppTheme.whiteColor),//colors.onPrimary),
              ),
            ),

            const Spacer(flex: 2),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0.5,
                backgroundColor: MandarinaAppTheme.secondaryColor,//colors.tertiary,
                foregroundColor: MandarinaAppTheme.accentColor,//colors.onTertiary,
                minimumSize: const Size(double.infinity, 60), 
                padding: EdgeInsets.zero, 
              ),
              onPressed: () => context.pushNamed(SignupScreen.name), // TODO: Ir a registrarse
              child: Text(
                '¡Empecemos ahora!',
                style: GoogleFonts.quicksand(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: OutlinedButton.styleFrom(
                elevation: 0.5,
                // Si quieres que uno sea distinto, puedes sobreescribir aquí
                side: BorderSide(
                  color: MandarinaAppTheme.secondaryColor,//colors.secondary,
                  width: 2,
                ),
                backgroundColor: MandarinaAppTheme.primaryColor,//colors.primary,
                minimumSize: const Size(double.infinity, 60), 
                padding: EdgeInsets.zero, 
              ),
              onPressed: ()=> context.pushNamed(LoginScreen.name), // Ir al login
              child: Text(
                'Ya tengo cuenta',
                style: GoogleFonts.quicksand(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  ),
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
