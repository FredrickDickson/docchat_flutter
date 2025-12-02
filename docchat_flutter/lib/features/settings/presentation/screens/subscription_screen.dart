import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../providers/subscription_provider.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  int _currentNavIndex = 3;

  @override
  void initState() {
    super.initState();
    // Load subscription when screen is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState.status == AuthStatus.authenticated && authState.user != null) {
        ref.read(subscriptionProvider.notifier).loadSubscription(authState.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final subscriptionState = ref.watch(subscriptionProvider);

    if (authState.status != AuthStatus.authenticated || authState.user == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Subscription'),
          centerTitle: true,
        ),
        body: const Center(child: Text('Please log in to view your subscription')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Subscription'),
        centerTitle: true,
      ),
      body: subscriptionState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Plan Card
                  _buildPlanCard(theme, subscriptionState),
                  
                  const SizedBox(height: AppDimensions.spacing32),
                  
                  // Plan Details
                  _buildPlanDetails(theme, subscriptionState),
                  
                  const SizedBox(height: AppDimensions.spacing32),
                  
                  // Upgrade/Downgrade Actions
                  if (subscriptionState.plan == 'free')
                    _buildUpgradeSection(theme)
                  else
                    _buildManageSubscriptionSection(theme, subscriptionState),
                  
                  // Error message
                  if (subscriptionState.error != null) ...[
                    const SizedBox(height: AppDimensions.spacing16),
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingMD),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: AppDimensions.spacing8),
                          Expanded(
                            child: Text(
                              subscriptionState.error!,
                              style: TextStyle(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildPlanCard(ThemeData theme, SubscriptionState state) {
    final isPro = state.plan == 'pro';
    final planName = isPro ? 'Pro' : 'Free';
    final planColor = isPro ? theme.colorScheme.primary : theme.colorScheme.secondary;

    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          gradient: LinearGradient(
            colors: [
              planColor.withValues(alpha: 0.1),
              planColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Plan',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing4),
                    Text(
                      planName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: planColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMD,
                    vertical: AppDimensions.paddingSM,
                  ),
                  decoration: BoxDecoration(
                    color: planColor,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: Text(
                    planName.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (isPro && state.currentPeriodEnd != null) ...[
              const SizedBox(height: AppDimensions.spacing16),
              Divider(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
              const SizedBox(height: AppDimensions.spacing8),
              Text(
                'Renews on: ${_formatDate(state.currentPeriodEnd!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlanDetails(ThemeData theme, SubscriptionState state) {
    final isPro = state.plan == 'pro';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan Features',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacing16),
        _buildFeatureItem(theme, Icons.description_outlined, 'Unlimited document uploads'),
        _buildFeatureItem(theme, Icons.chat_bubble_outline, 'AI-powered document chat'),
        _buildFeatureItem(theme, Icons.storage_outlined, 'Cloud storage'),
        if (isPro) ...[
          _buildFeatureItem(theme, Icons.speed_outlined, 'Priority processing'),
          _buildFeatureItem(theme, Icons.support_agent_outlined, 'Priority support'),
        ],
      ],
    );
  }

  Widget _buildFeatureItem(ThemeData theme, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: AppDimensions.spacing12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Upgrade to Pro',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacing8),
        Text(
          'Get access to priority processing, advanced features, and priority support.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.spacing24),
        FilledButton(
          onPressed: () {
            // TODO: Implement Paystack payment flow
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Upgrade to Pro - Payment integration coming soon'),
                backgroundColor: Colors.orange,
              ),
            );
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Upgrade to Pro'),
        ),
      ],
    );
  }

  Widget _buildManageSubscriptionSection(ThemeData theme, SubscriptionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Manage Subscription',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacing24),
        OutlinedButton(
          onPressed: () {
            // TODO: Implement cancel subscription
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cancel subscription feature coming soon'),
                backgroundColor: Colors.orange,
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Cancel Subscription'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _onNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/home-auth');
        break;
      case 1:
        context.go('/dashboard');
        break;
      case 2:
        context.go('/upload');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }
}

