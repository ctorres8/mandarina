import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandarina/core/router/app_router.dart';
import 'package:mandarina/core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MandarinaApp()));
}

class MandarinaApp extends StatelessWidget {
  const MandarinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mandarina Ecosistema',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: mandarinaAppTheme.mandarinaTheme,
    );
  }
}
