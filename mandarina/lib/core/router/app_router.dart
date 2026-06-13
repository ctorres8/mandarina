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

final appRouter = GoRouter(
  initialLocation: '/',

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
          path: 'pet', // ruta: /home/profile
          name: PetScreen.name,
          builder: (context, state) => const PetScreen(),
        ),
        GoRoute(
          path: 'freelancer', // ruta: /home/profile
          name: FreelancerScreen.name,
          builder: (context, state) => const FreelancerScreen(),
        ),
        GoRoute(
          path: 'settings', // ruta: /home/profile
          name: SettingsScreen.name,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: 'about', // ruta: /home/profile
          name: AboutScreen.name,
          builder: (context, state) => const AboutScreen(),
        ),
      ],
    ),
  ],

  /*
  routes: [
    GoRoute(
      path: '/',
      name: LandingScreen.name,
      builder:(context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/landing/login',
      name: LoginScreen.name,
      builder:(context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/landing/login/forgotpass',
      name: ForgotPasswordScreen.name,
      builder:(context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/landing/signup',
      name: SignupScreen.name,
      builder:(context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/landing/login/home',
      name: HomeScreen.name,
      builder:(context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/landing/login/home/profile',
      name: ProfileScreen.name,
      builder:(context, state) => const ProfileScreen(),
    ),
  ]
  */
);
