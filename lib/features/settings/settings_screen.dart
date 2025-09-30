import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/revenuecat_provider.dart';
import '../../routing/router.dart';
import '../../theme/theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenueCatState = ref.watch(revenueCatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium status
            _buildPremiumStatus(context, revenueCatState.isPremium),
            const SizedBox(height: AppTheme.spacing6),
            
            // Account section
            _buildSectionHeader(context, 'Account'),
            _buildAccountSection(context, ref, revenueCatState.isPremium),
            const SizedBox(height: AppTheme.spacing6),
            
            // Preferences section
            _buildSectionHeader(context, 'Preferences'),
            _buildPreferencesSection(context),
            const SizedBox(height: AppTheme.spacing6),
            
            // Data section
            _buildSectionHeader(context, 'Data'),
            _buildDataSection(context),
            const SizedBox(height: AppTheme.spacing6),
            
            // About section
            _buildSectionHeader(context, 'About'),
            _buildAboutSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumStatus(BuildContext context, bool isPremium) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        gradient: isPremium ? AppTheme.primaryGradient : null,
        color: isPremium ? null : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.lightShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing3),
            decoration: BoxDecoration(
              color: isPremium ? Colors.white.withOpacity(0.2) : AppTheme.primaryPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPremium ? Icons.workspace_premium : Icons.lock_outline,
              color: isPremium ? Colors.white : AppTheme.primaryPurple,
              size: 32,
            ),
          ),
          const SizedBox(width: AppTheme.spacing4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPremium ? 'Premium Member' : 'Free Plan',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: isPremium ? Colors.white : null,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing1),
                Text(
                  isPremium 
                      ? 'Enjoying unlimited entries and AI reflections'
                      : 'Upgrade to unlock all features',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isPremium ? Colors.white.withOpacity(0.9) : null,
                  ),
                ),
              ],
            ),
          ),
          if (!isPremium)
            TextButton(
              onPressed: () => AppRouter.goToPaywall(context),
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
                foregroundColor: AppTheme.primaryPurple,
              ),
              child: const Text('Upgrade'),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing3),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, WidgetRef ref, bool isPremium) {
    return Column(
      children: [
        if (isPremium) ...[
          _buildSettingsItem(
            context,
            icon: Icons.card_membership,
            title: 'Manage Subscription',
            subtitle: 'View and manage your subscription',
            onTap: () {
              // TODO: Open subscription management
              _showNotImplemented(context);
            },
          ),
          _buildSettingsItem(
            context,
            icon: Icons.restore,
            title: 'Restore Purchases',
            subtitle: 'Restore previous purchases',
            onTap: () => _restorePurchases(ref),
          ),
        ] else ...[
          _buildSettingsItem(
            context,
            icon: Icons.upgrade,
            title: 'Upgrade to Premium',
            subtitle: 'Unlock all features',
            onTap: () => AppRouter.goToPaywall(context),
          ),
        ],
      ],
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
    return Column(
      children: [
        _buildSettingsItem(
          context,
          icon: Icons.palette_outlined,
          title: 'Theme',
          subtitle: 'System default',
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showThemeDialog(context),
        ),
        _buildSettingsItem(
          context,
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Daily reminders and throwbacks',
          trailing: Switch(
            value: true, // TODO: Connect to actual setting
            onChanged: (value) {
              // TODO: Implement notification settings
            },
          ),
        ),
        _buildSettingsItem(
          context,
          icon: Icons.mic_outlined,
          title: 'Audio Quality',
          subtitle: 'High quality recording',
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showAudioQualityDialog(context),
        ),
      ],
    );
  }

  Widget _buildDataSection(BuildContext context) {
    return Column(
      children: [
        _buildSettingsItem(
          context,
          icon: Icons.download_outlined,
          title: 'Export Data',
          subtitle: 'Download your journal entries',
          onTap: () => _exportData(context),
        ),
        _buildSettingsItem(
          context,
          icon: Icons.cloud_sync_outlined,
          title: 'Backup & Sync',
          subtitle: 'Coming soon',
          trailing: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing2,
              vertical: AppTheme.spacing1,
            ),
            decoration: BoxDecoration(
              color: AppTheme.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Text(
              'Soon',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        _buildSettingsItem(
          context,
          icon: Icons.delete_outline,
          title: 'Delete All Data',
          subtitle: 'Permanently delete all entries',
          titleColor: AppTheme.error,
          onTap: () => _showDeleteAllDialog(context),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      children: [
        _buildSettingsItem(
          context,
          icon: Icons.info_outline,
          title: 'Version',
          subtitle: '1.0.0 (1)',
        ),
        _buildSettingsItem(
          context,
          icon: Icons.article_outlined,
          title: 'Privacy Policy',
          onTap: () => _openPrivacyPolicy(context),
        ),
        _buildSettingsItem(
          context,
          icon: Icons.gavel_outlined,
          title: 'Terms of Service',
          onTap: () => _openTermsOfService(context),
        ),
        _buildSettingsItem(
          context,
          icon: Icons.code_outlined,
          title: 'Open Source Licenses',
          onTap: () => _showLicensePage(context),
        ),
        _buildSettingsItem(
          context,
          icon: Icons.feedback_outlined,
          title: 'Send Feedback',
          onTap: () => _sendFeedback(context),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing2),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacing4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing2),
                  decoration: BoxDecoration(
                    color: (titleColor ?? Theme.of(context).primaryColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Icon(
                    icon,
                    color: titleColor ?? Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppTheme.spacing1),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _restorePurchases(WidgetRef ref) {
    // TODO: Implement restore purchases
    ScaffoldMessenger.of(ref.context).showSnackBar(
      const SnackBar(
        content: Text('Restoring purchases...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('System Default'),
              value: 'system',
              groupValue: 'system',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: const Text('Light'),
              value: 'light',
              groupValue: 'system',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: const Text('Dark'),
              value: 'dark',
              groupValue: 'system',
              onChanged: (value) => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAudioQualityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Audio Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('High Quality'),
              subtitle: const Text('Better quality, larger files'),
              value: 'high',
              groupValue: 'high',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: const Text('Standard'),
              subtitle: const Text('Good quality, smaller files'),
              value: 'standard',
              groupValue: 'high',
              onChanged: (value) => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context) {
    // TODO: Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data export feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
          'This will permanently delete all your journal entries and cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete all data
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data deleted'),
                  backgroundColor: AppTheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _openPrivacyPolicy(BuildContext context) {
    // TODO: Open privacy policy URL
    _showNotImplemented(context);
  }

  void _openTermsOfService(BuildContext context) {
    // TODO: Open terms of service URL
    _showNotImplemented(context);
  }

  void _showLicensePage(BuildContext context) {
    showLicensePage(context: context, applicationName: 'EchoJournal');
  }

  void _sendFeedback(BuildContext context) {
    // TODO: Open feedback form or email
    _showNotImplemented(context);
  }

  void _showNotImplemented(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
} 