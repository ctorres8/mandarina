import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:mandarina/data/repositories/user_repository.dart';
import 'package:mandarina/presentation/screens/home_screen.dart';
import 'package:mandarina/presentation/viewmodel/auth_providers.dart';
import 'package:mandarina/presentation/widgets/tyc_bottomsheet.dart';

/// Centraliza el flujo de autenticación con Google verificando y persistiendo
/// el estado de aceptación de los Términos y Condiciones.
Future<void> handleGoogleAuthTermsFlow(
  BuildContext context,
  WidgetRef ref, {
  bool preAcceptedTerms = false,
}) async {
  FocusManager.instance.primaryFocus?.unfocus();

  // Prevenir redirecciones automáticas del router mientras se valida el estado de TyC
  ref.read(preventRedirectProvider.notifier).state = true;

  try {
    final success = await ref
        .read(authControllerProvider.notifier)
        .signInWithGoogle();

    if (!success) {
      ref.read(preventRedirectProvider.notifier).state = false;
      if (context.mounted) {
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
      return;
    }

    final user = ref.read(firebaseAuthServiceProvider).currentUser;
    if (user == null) {
      ref.read(preventRedirectProvider.notifier).state = false;
      return;
    }

    final userRepository = ref.read(userRepositoryProvider);
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final bool userDocExists = userDoc.exists && userDoc.data() != null;
    final bool hasAcceptedInDb = userDocExists &&
        ((userDoc.data()?['hasAcceptedTerms'] == true) ||
            (userDoc.data()?['acceptedTerms'] == true));

    final bool isTermsAccepted = preAcceptedTerms || hasAcceptedInDb;

    if (isTermsAccepted) {
      if (!userDocExists) {
        // Crear perfil inicial de usuario con la marca de TyC aceptados
        await userRepository.createUserProfileAfterSignup(
          user.uid,
          user.email ?? '',
        );
      } else if (!hasAcceptedInDb) {
        // Si el perfil existía pero no tenía la marca, actualizarla sin borrar el perfil
        await userRepository.markTermsAccepted(user.uid);
      }

      ref.read(preventRedirectProvider.notifier).state = false;
      if (context.mounted) {
        context.goNamed(HomeScreen.name);
      }
    } else {
      // Si aún no aceptó los TyC (ej. primer ingreso por login_screen), mostrar BottomSheet
      bool acceptedNow = false;
      if (context.mounted) {
        await showTermsBottomSheet(
          context,
          onAccepted: () {
            acceptedNow = true;
          },
        );
      }

      if (acceptedNow) {
        if (!userDocExists) {
          await userRepository.createUserProfileAfterSignup(
            user.uid,
            user.email ?? '',
          );
        } else {
          await userRepository.markTermsAccepted(user.uid);
        }

        ref.read(preventRedirectProvider.notifier).state = false;
        if (context.mounted) {
          context.goNamed(HomeScreen.name);
        }
      } else {
        // Si rechaza o cierra el BottomSheet sin aceptar, cerramos sesión
        await ref.read(authControllerProvider.notifier).signOut();
        ref.read(preventRedirectProvider.notifier).state = false;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Debes aceptar los Términos y Condiciones para ingresar.',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
              ),
              backgroundColor: MandarinaAppTheme.blueColor,
            ),
          );
        }
      }
    }
  } catch (e) {
    ref.read(preventRedirectProvider.notifier).state = false;
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ocurrió un error al procesar el ingreso.',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
          ),
          backgroundColor: MandarinaAppTheme.blueColor,
        ),
      );
    }
  }
}
