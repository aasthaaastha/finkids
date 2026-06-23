import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'navigation/app_router.dart';

/// Root widget. Uses ConsumerWidget so it can read Riverpod providers.
class FinKidsApp extends ConsumerWidget {
  const FinKidsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the GoRouter instance provided by Riverpod
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'FinKids',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
