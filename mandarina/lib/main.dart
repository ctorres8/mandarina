import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandarina/core/router/app_router.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MandarinaApp()));
}

class MandarinaApp extends ConsumerWidget {
  const MandarinaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Mandarina Ecosistema',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: mandarinaAppTheme.mandarinaTheme,
    );
  }
}

