import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routing/router.dart';
import 'theme/theme.dart';

class EchoJournalApp extends ConsumerWidget {
  const EchoJournalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'EchoJournal',
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Follow system theme
      
      // Router configuration
      routerConfig: AppRouter.router,
      
      // App metadata
      builder: (context, child) {
        return MediaQuery(
          // Ensure text doesn't scale beyond reasonable limits
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.4),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );
  }
} 