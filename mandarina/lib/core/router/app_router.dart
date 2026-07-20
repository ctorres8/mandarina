import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mandarina/presentation/screens/about_screen.dart';
import 'package:mandarina/presentation/screens/auth/forgot_password_screen.dart';
import 'package:mandarina/presentation/screens/auth/login_screen.dart';
import 'package:mandarina/presentation/screens/auth/signup_screen.dart';
import 'package:mandarina/presentation/screens/workflow_screen.dart';
import 'package:mandarina/presentation/screens/home_screen.dart';
import 'package:mandarina/presentation/screens/landing_screen.dart';
import 'package:mandarina/presentation/screens/pet_screen.dart';
import 'package:mandarina/presentation/screens/profile_screen.dart';
import 'package:mandarina/presentation/screens/settings_screen.dart';
import 'package:mandarina/presentation/viewmodel/auth_providers.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen(authStateChangesProvider, (previous, next) {
      notifyListeners();
    });
    _ref.listen(showSignupDialogProvider, (previous, next) {
      notifyListeners();
    });
    _ref.listen(preventRedirectProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: listenable,
    redirect: (context, state) {
      final showSignupDialog = ref.read(showSignupDialogProvider);
      final preventRedirect = ref.read(preventRedirectProvider);
      if (showSignupDialog || preventRedirect) {
        return null;
      }
      final user = ref.read(authStateChangesProvider).value;
      final isLoggedIn = user != null;

      // Rutas de autenticación / públicas
      final isGoingToLanding = state.matchedLocation == '/';
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToSignup = state.matchedLocation == '/signup';
      final isGoingToForgot = state.matchedLocation == '/login/forgotpass';

      final isGoingToAuth =
          isGoingToLanding ||
          isGoingToLogin ||
          isGoingToSignup ||
          isGoingToForgot;

      if (!isLoggedIn) {
        if (!isGoingToAuth) {
          return '/';
        }
      } else {
        if (isGoingToAuth) {
          if (state.matchedLocation == '/signup') {
            return null; // Permitir que el usuario se quede para interactuar con el diálogo
          }
          return '/home';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: LandingScreen.name,
        builder: (context, state) => const LandingScreen(),
        routes: [
          GoRoute(
            path: 'login', // ruta /login
            name: LoginScreen.name,
            builder: (context, state) => const LoginScreen(),
            routes: [
              GoRoute(
                path: 'forgotpass', // ruta: /login/forgotpass
                name: ForgotPasswordScreen.name,
                builder: (context, state) => const ForgotPasswordScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'signup', // ruta: /signup
            name: SignupScreen.name,
            builder: (context, state) => const SignupScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/home', // ruta: /home
        name: HomeScreen.name,
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'profile', // ruta: /home/profile
            name: ProfileScreen.name,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: 'pet', // ruta: /home/pet
            name: PetScreen.name,
            builder: (context, state) => const PetScreen(),
          ),
          GoRoute(
            path: 'freelancer', // ruta: /home/freelancer
            name: FreelancerScreen.name,
            builder: (context, state) => const FreelancerScreen(),
          ),
          GoRoute(
            path: 'settings', // ruta: /home/settings
            name: SettingsScreen.name,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'about', // ruta: /home/about
            name: AboutScreen.name,
            builder: (context, state) => const AboutScreen(),
          ),
        ],
      ),
    ],
  );
});
