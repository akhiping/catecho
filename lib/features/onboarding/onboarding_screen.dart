import 'package:flutter/material.dart';
import '../../routing/router.dart';
import '../../theme/theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mic,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                'Welcome to EchoJournal',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing4),
              Text(
                'Your AI-powered voice diary for capturing daily thoughts and reflections.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing12),
              ElevatedButton(
                onPressed: () => AppRouter.goToHome(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                child: const Text('Start Free'),
              ),
              const SizedBox(height: AppTheme.spacing4),
              TextButton(
                onPressed: () {
                  // TODO: Implement restore purchases
                  AppRouter.goToHome(context);
                },
                child: const Text('Restore Purchases'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 