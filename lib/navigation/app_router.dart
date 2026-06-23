import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding/screens/splash_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/learn/screens/learn_screen.dart';
import '../features/learn/screens/lesson_screen.dart';
import '../features/learn/screens/quiz_screen.dart';
import '../features/expenses/screens/expenses_screen.dart';
import '../features/expenses/screens/add_expense_screen.dart';
import '../features/location/screens/location_screen.dart';
import 'shell_navigator.dart';

// ─────────────────────────────────────────────
// Route path constants — change paths in one place
// ─────────────────────────────────────────────
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const learn = '/learn';
  static const lesson = '/learn/lesson/:moduleId'; // named param
  static const quiz = '/learn/quiz/:moduleId';
  static const expenses = '/expenses';
  static const addExpense = '/expenses/add';
  static const location = '/location';
}

// ─────────────────────────────────────────────
// Navigator keys — one per tab + a root key
// StatefulShellRoute needs separate keys so each
// tab keeps its own navigation stack.
// ─────────────────────────────────────────────
final _rootKey = GlobalKey<NavigatorState>();
final _homeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _learnKey = GlobalKey<NavigatorState>(debugLabel: 'learn');
final _expensesKey = GlobalKey<NavigatorState>(debugLabel: 'expenses');
final _locationKey = GlobalKey<NavigatorState>(debugLabel: 'location');

// ─────────────────────────────────────────────
// Router provider
// ─────────────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true, // set false before release
    routes: [
      // ── Splash ──────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Onboarding ──────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ── Main shell (bottom nav) ──────────────
      // StatefulShellRoute keeps each tab's scroll position and
      // back-stack alive when you switch tabs.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellNavigator(navigationShell: navigationShell),
        branches: [
          // Tab 1 — Home
          StatefulShellBranch(
            navigatorKey: _homeKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Tab 2 — Learn (nested routes)
          StatefulShellBranch(
            navigatorKey: _learnKey,
            routes: [
              GoRoute(
                path: AppRoutes.learn,
                builder: (context, state) => const LearnScreen(),
                routes: [
                  GoRoute(
                    path: 'lesson/:moduleId',
                    builder: (context, state) => LessonScreen(
                      moduleId: state.pathParameters['moduleId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'quiz/:moduleId',
                    builder: (context, state) => QuizScreen(
                      moduleId: state.pathParameters['moduleId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Tab 3 — Expenses
          StatefulShellBranch(
            navigatorKey: _expensesKey,
            routes: [
              GoRoute(
                path: AppRoutes.expenses,
                builder: (context, state) => const ExpensesScreen(),
                routes: [
                  GoRoute(
                    // parentNavigatorKey = _rootKey → renders above the shell
                    // (full-screen modal, no bottom nav visible)
                    path: 'add',
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => const AddExpenseScreen(),
                  ),
                ],
              ),
            ],
          ),

          // Tab 4 — Location
          StatefulShellBranch(
            navigatorKey: _locationKey,
            routes: [
              GoRoute(
                path: AppRoutes.location,
                builder: (context, state) => const LocationScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
