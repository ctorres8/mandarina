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

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = authState.value;
      final isLoggedIn = user != null &&
          (user.emailVerified ||
              user.providerData.any((p) => p.providerId == 'google.com'));

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
