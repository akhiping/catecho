import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding/onboarding_screen.dart';
import '../features/timeline/timeline_screen.dart';
import '../features/recorder/recorder_screen.dart';
import '../features/entry/entry_detail_sheet.dart';
import '../features/paywall/paywall_screen.dart';
import '../features/settings/settings_screen.dart';

class AppRouter {
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String timeline = '/timeline';
  static const String recorder = '/recorder';
  static const String entryDetail = '/entry/:entryId';
  static const String paywall = '/paywall';
  static const String settings = '/settings';

  static final GoRouter _router = GoRouter(
    initialLocation: home,
    debugLogDiagnostics: true,
    routes: [
      // Onboarding route
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),

      // Main shell route with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // Timeline/Home route
          GoRoute(
            path: home,
            name: 'home',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const TimelineScreen(),
            ),
          ),

          // Settings route
          GoRoute(
            path: settings,
            name: 'settings',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
          ),
        ],
      ),

      // Recorder route (full screen)
      GoRoute(
        path: recorder,
        name: 'recorder',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const RecorderScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              ),
        ),
      ),

      // Entry detail route (modal)
      GoRoute(
        path: entryDetail,
        name: 'entryDetail',
        pageBuilder: (context, state) {
          final entryId = state.pathParameters['entryId']!;
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: EntryDetailSheet(entryId: entryId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                SlideTransition(
                  position: animation.drive(
                    Tween<Offset>(
                      begin: const Offset(0.0, 1.0),
                      end: Offset.zero,
                    ).chain(CurveTween(curve: Curves.easeInOut)),
                  ),
                  child: child,
                ),
          );
        },
      ),

      // Paywall route (modal)
      GoRoute(
        path: paywall,
        name: 'paywall',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const PaywallScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              ),
        ),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );

  static GoRouter get router => _router;

  // Helper methods for navigation
  static void goToOnboarding(BuildContext context) {
    context.go(onboarding);
  }

  static void goToHome(BuildContext context) {
    context.go(home);
  }

  static void goToRecorder(BuildContext context) {
    context.push(recorder);
  }

  static void goToEntryDetail(BuildContext context, String entryId) {
    context.push(entryDetail.replaceAll(':entryId', entryId));
  }

  static void goToPaywall(BuildContext context) {
    context.push(paywall);
  }

  static void goToSettings(BuildContext context) {
    context.go(settings);
  }

  static void pop(BuildContext context) {
    context.pop();
  }
}

// Main shell widget for bottom navigation
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      floatingActionButton: _buildFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => AppRouter.goToRecorder(context),
        child: const Icon(Icons.mic, size: 28),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
            isActive: currentLocation == AppRouter.home,
            onTap: () => AppRouter.goToHome(context),
          ),
          const SizedBox(width: 40), // Space for FAB
          _buildNavItem(
            context,
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'Settings',
            isActive: currentLocation == AppRouter.settings,
            onTap: () => AppRouter.goToSettings(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final color = isActive ? theme.primaryColor : theme.iconTheme.color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// Error screen
class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong.',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => AppRouter.goToHome(context),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
} 