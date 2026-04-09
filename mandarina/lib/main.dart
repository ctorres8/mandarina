import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandarina/core/router/app_router.dart';
import 'package:mandarina/core/theme/app_theme.dart';


void main() {
  runApp(
    const ProviderScope(
      child: MainApp()
    )
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner:  false,
      theme: mandarinaAppTheme.mandarinaTheme,
      routerConfig: appRouter,
    );
  }
}
