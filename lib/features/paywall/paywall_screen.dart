import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/revenuecat_provider.dart';
import '../../routing/router.dart';
import '../../theme/theme.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenueCatState = ref.watch(revenueCatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
        leading: IconButton(
          onPressed: () => AppRouter.pop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppTheme.spacing8),
            _buildFeaturesList(context),
            const SizedBox(height: AppTheme.spacing8),
            _buildSubscriptionPlans(context, ref, revenueCatState),
            const SizedBox(height: AppTheme.spacing8),
            _buildMemoryPacks(context, ref),
            const SizedBox(height: AppTheme.spacing6),
            _buildRestoreButton(context, ref),
            const SizedBox(height: AppTheme.spacing4),
            _buildTermsText(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing6),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.auto_awesome,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppTheme.spacing4),
        Text(
          'Unlock Your Full Potential',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacing2),
        Text(
          'Get unlimited entries, AI reflections, and premium features',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      {
        'icon': Icons.all_inclusive,
        'title': 'Unlimited Entries',
        'description': 'Record as many voice entries as you want',
        'isPremium': true,
      },
      {
        'icon': Icons.psychology,
        'title': 'AI Reflections',
        'description': 'Get personalized insights from your thoughts',
        'isPremium': true,
      },
      {
        'icon': Icons.mood,
        'title': 'Mood Tracking',
        'description': 'Automatic mood detection and trends',
        'isPremium': true,
      },
      {
        'icon': Icons.history,
        'title': 'Memory Throwbacks',
        'description': 'Daily reminders of past entries',
        'isPremium': true,
      },
      {
        'icon': Icons.palette,
        'title': 'Custom Themes',
        'description': 'Personalize your journal experience',
        'isPremium': true,
      },
      {
        'icon': Icons.mic,
        'title': 'Basic Recording',
        'description': '1 entry per day with transcription',
        'isPremium': false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s Included',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacing4),
        ...features.map((feature) => _buildFeatureItem(
          context,
          feature['icon'] as IconData,
          feature['title'] as String,
          feature['description'] as String,
          feature['isPremium'] as bool,
        )),
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    bool isPremium,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing3),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing2),
            decoration: BoxDecoration(
              color: isPremium
                  ? AppTheme.primaryPurple.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(
              icon,
              color: isPremium ? AppTheme.primaryPurple : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isPremium) ...[
                      const SizedBox(width: AppTheme.spacing1),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'PRO',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlans(
    BuildContext context,
    WidgetRef ref,
    RevenueCatState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Plan',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacing4),
        _buildPlanCard(
          context,
          title: 'Monthly',
          price: '\$4.99',
          period: 'per month',
          description: 'Perfect for trying premium features',
          isPopular: false,
          onTap: () => _purchaseSubscription(ref, 'monthly'),
        ),
        const SizedBox(height: AppTheme.spacing3),
        _buildPlanCard(
          context,
          title: 'Yearly',
          price: '\$29.99',
          period: 'per year',
          description: 'Save 50% with annual billing',
          savings: 'Save \$30',
          isPopular: true,
          onTap: () => _purchaseSubscription(ref, 'yearly'),
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    required String description,
    String? savings,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: isPopular ? AppTheme.primaryPurple : Colors.transparent,
          width: 2,
        ),
        boxShadow: isPopular ? AppTheme.mediumShadow : AppTheme.lightShadow,
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacing4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              gradient: isPopular
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryPurple.withOpacity(0.05),
                        AppTheme.primaryTeal.withOpacity(0.05),
                      ],
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (savings != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing2,
                          vertical: AppTheme.spacing1,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: Text(
                          savings,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing2),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: price,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isPopular ? AppTheme.primaryPurple : null,
                        ),
                      ),
                      TextSpan(
                        text: ' $period',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacing2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppTheme.spacing4),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPopular ? AppTheme.primaryPurple : null,
                    ),
                    child: const Text('Subscribe'),
                  ),
                ),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: 0,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing3,
                  vertical: AppTheme.spacing1,
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(AppTheme.radiusSmall),
                  ),
                ),
                child: Text(
                  'POPULAR',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMemoryPacks(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Memory Packs',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacing2),
        Text(
          'One-time purchases for specialized AI reflections',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppTheme.spacing4),
        Row(
          children: [
            Expanded(
              child: _buildMemoryPackCard(
                context,
                title: 'Gratitude Pack',
                description: 'Focus on appreciation and thankfulness',
                price: '\$1.99',
                icon: Icons.favorite,
                color: AppTheme.accent1,
                onTap: () => _purchaseMemoryPack(ref, 'gratitude'),
              ),
            ),
            const SizedBox(width: AppTheme.spacing3),
            Expanded(
              child: _buildMemoryPackCard(
                context,
                title: 'Growth Pack',
                description: 'Insights for personal development',
                price: '\$1.99',
                icon: Icons.trending_up,
                color: AppTheme.accent2,
                onTap: () => _purchaseMemoryPack(ref, 'growth'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMemoryPackCard(
    BuildContext context, {
    required String title,
    required String description,
    required String price,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.lightShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing3),
          Text(
            price,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
              ),
              child: const Text('Buy'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => _restorePurchases(ref),
        child: const Text('Restore Purchases'),
      ),
    );
  }

  Widget _buildTermsText(BuildContext context) {
    return Text(
      'Subscriptions will be charged to your credit card through your App Store or Google Play account. Your subscription will automatically renew unless cancelled at least 24 hours before the end of the current period.',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
      ),
      textAlign: TextAlign.center,
    );
  }

  void _purchaseSubscription(WidgetRef ref, String type) {
    // TODO: Implement subscription purchase
    ScaffoldMessenger.of(ref.context).showSnackBar(
      SnackBar(
        content: Text('$type subscription purchase - implement with RevenueCat'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _purchaseMemoryPack(WidgetRef ref, String packType) {
    // TODO: Implement memory pack purchase
    ScaffoldMessenger.of(ref.context).showSnackBar(
      SnackBar(
        content: Text('$packType pack purchase - implement with RevenueCat'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _restorePurchases(WidgetRef ref) {
    // TODO: Implement restore purchases
    ScaffoldMessenger.of(ref.context).showSnackBar(
      const SnackBar(
        content: Text('Restore purchases - implement with RevenueCat'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
} 