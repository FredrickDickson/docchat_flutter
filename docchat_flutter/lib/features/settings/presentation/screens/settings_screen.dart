import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _currentNavIndex = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: AppDimensions.spacing16),
          
          _buildSectionHeader(context, 'Appearance'),
          ListTile(
            leading: Icon(
              Icons.dark_mode,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: isDark,
              onChanged: (value) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ),
          
          const Divider(height: AppDimensions.spacing32),
          
          _buildSectionHeader(context, 'Account'),
          ListTile(
            leading: Icon(
              Icons.person_outline,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/profile'),
          ),
          ListTile(
            leading: Icon(
              Icons.workspace_premium,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Subscription'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Subscription settings coming soon')),
              );
            },
          ),
          
          const Divider(height: AppDimensions.spacing32),
          
          _buildSectionHeader(context, 'Notifications'),
          SwitchListTile(
            secondary: Icon(
              Icons.notifications_outlined,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Push Notifications'),
            value: true,
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification settings coming soon')),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.email_outlined,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Email Notifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email notification settings coming soon')),
              );
            },
          ),
          
          const Divider(height: AppDimensions.spacing32),
          
          _buildSectionHeader(context, 'Support & Legal'),
          ListTile(
            leading: Icon(
              Icons.help_outline,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Help Center'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help Center coming soon')),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.headset_mic_outlined,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Contact Us'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/contact'),
          ),
          ListTile(
            leading: Icon(
              Icons.privacy_tip_outlined,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => context.go('/privacy'),
          ),
          ListTile(
            leading: Icon(
              Icons.gavel_outlined,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => context.go('/terms'),
          ),
          
          const SizedBox(height: AppDimensions.spacing32),
          
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMD,
            ),
            child: OutlinedButton(
              onPressed: () {
                ref.read(authProvider.notifier).signOut();
                context.go('/');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Log Out'),
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing16),
          
          Center(
            child: Text(
              'DocChat v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing32),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
    );
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
        break;
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: AppDimensions.spacing8,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
