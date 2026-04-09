import 'package:go_router/go_router.dart';
import 'package:mandarina/presentation/screens/auth/forgot_password_screen.dart';
import 'package:mandarina/presentation/screens/auth/login_screen.dart';
import 'package:mandarina/presentation/screens/auth/signup_screen.dart';
import 'package:mandarina/presentation/screens/home_screen.dart';
import 'package:mandarina/presentation/screens/landing_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',

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
  ]


);
