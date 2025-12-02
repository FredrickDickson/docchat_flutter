import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _selectedImage;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final authState = ref.read(authProvider);
    if (authState.status == AuthStatus.authenticated && authState.user != null) {
      ref.read(profileProvider.notifier).loadProfile(authState.user!.id);
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final profileState = ref.watch(profileProvider);
    final user = authState.user;

    // Update controllers when profile loads
    if (profileState.profile != null && _displayNameController.text.isEmpty) {
      _displayNameController.text = profileState.profile!.displayName ?? '';
    }
    if (user != null && _emailController.text.isEmpty) {
      _emailController.text = user.email;
    }


    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Please log in to view your profile')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: profileState.isLoading && profileState.profile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              child: Form(
                key: _formKey,
                onChanged: () {
                  setState(() {
                    _hasChanges = true;
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppDimensions.spacing16),

                    // Avatar
                    _buildAvatar(theme, profileState),

                    const SizedBox(height: AppDimensions.spacing32),

                    // Full Name
                    CustomTextField(
                      controller: _displayNameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Full name is required';
                        }
                        if (value.trim().length < 2) {
                          return 'Full name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppDimensions.spacing16),

                    // Email (read-only)
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'john.doe@example.com',
                      prefixIcon: Icons.email_outlined,
                      enabled: false,
                    ),

                    const SizedBox(height: AppDimensions.spacing16),

                    // Phone Number
                    CustomTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: 'Add phone number',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: AppDimensions.spacing32),

                    // Error message
                    if (profileState.error != null) ...[
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
                                profileState.error!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing16),
                    ],

                    // Save Changes Button
                    CustomButton(
                      text: 'Save Changes',
                      onPressed: _hasChanges || _selectedImage != null
                          ? () => _saveProfile(user.id)
                          : null,
                      isLoading: profileState.isLoading,
                      width: double.infinity,
                    ),

                    const SizedBox(height: AppDimensions.spacing32),

                    // Account Settings Section
                    _buildSectionHeader(theme, 'Account Settings'),
                    const SizedBox(height: AppDimensions.spacing8),
                    _buildSettingsTile(
                      theme,
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      onTap: () => _showChangePasswordDialog(context, theme),
                    ),

                    const SizedBox(height: AppDimensions.spacing24),

                    // More Options Section
                    _buildSectionHeader(theme, 'More Options'),
                    const SizedBox(height: AppDimensions.spacing8),
                    _buildSettingsTile(
                      theme,
                      icon: Icons.workspace_premium_outlined,
                      title: 'Subscription',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Subscription settings coming soon')),
                        );
                      },
                    ),
                    _buildSettingsTile(
                      theme,
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notification settings coming soon')),
                        );
                      },
                    ),

                    const SizedBox(height: AppDimensions.spacing32),

                    // Log Out Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showLogoutDialog(context, theme),
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          'Log Out',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacing16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAvatar(ThemeData theme, ProfileState profileState) {
    final avatarUrl = profileState.profile?.avatarUrl;
    final displayName = profileState.profile?.displayName ?? 'User';

    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.primary,
              width: 3,
            ),
          ),
          child: ClipOval(
            child: _selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  )
                : avatarUrl != null
                    ? Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildAvatarPlaceholder(theme, displayName);
                        },
                      )
                    : _buildAvatarPlaceholder(theme, displayName),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.surface,
                width: 2,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.camera_alt,
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              onPressed: _pickImage,
              tooltip: 'Change avatar',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarPlaceholder(ThemeData theme, String displayName) {
    return Container(
      color: theme.colorScheme.primaryContainer,
      child: Center(
        child: Text(
          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
          style: theme.textTheme.displayLarge?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _hasChanges = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile(String userId) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ref.read(profileProvider.notifier).clearError();

    // Upload avatar if selected
    if (_selectedImage != null) {
      final avatarUrl = await ref.read(profileProvider.notifier).uploadAvatar(
            userId: userId,
            imageFile: _selectedImage!,
          );

      if (avatarUrl == null) {
        // Error uploading avatar
        return;
      }
    }

    // Update display name
    final success = await ref.read(profileProvider.notifier).updateProfile(
          userId: userId,
          displayName: _displayNameController.text.trim(),
        );

    if (success && mounted) {
      setState(() {
        _hasChanges = false;
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing8),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, ThemeData theme) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Change Password'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: oldPasswordController,
                    label: 'Current Password',
                    hint: 'Enter current password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Current password is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  CustomTextField(
                    controller: newPasswordController,
                    label: 'New Password',
                    hint: 'Enter new password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'New password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  CustomTextField(
                    controller: confirmPasswordController,
                    label: 'Confirm New Password',
                    hint: 'Confirm new password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (formKey.currentState?.validate() ?? false) {
                        setDialogState(() {
                          isLoading = true;
                        });

                        try {
                          // TODO: Implement password change
                          // For now, show a placeholder message
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password change feature coming soon'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            Navigator.of(dialogContext).pop();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to change password: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            setDialogState(() {
                              isLoading = false;
                            });
                          }
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
              Navigator.of(dialogContext).pop();
              context.go('/');
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

