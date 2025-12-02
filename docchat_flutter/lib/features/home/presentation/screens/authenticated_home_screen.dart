import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../documents/presentation/providers/documents_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class AuthenticatedHomeScreen extends ConsumerStatefulWidget {
  const AuthenticatedHomeScreen({super.key});

  @override
  ConsumerState<AuthenticatedHomeScreen> createState() => _AuthenticatedHomeScreenState();
}

class _AuthenticatedHomeScreenState extends ConsumerState<AuthenticatedHomeScreen> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load documents and profile when screen is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(documentsProvider.notifier).loadDocuments();
      final authState = ref.read(authProvider);
      if (authState.status == AuthStatus.authenticated && authState.user != null) {
        ref.read(profileProvider.notifier).loadProfile(authState.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final profileState = ref.watch(profileProvider);
    final documentsState = ref.watch(documentsProvider);

    final user = authState.user;
    final displayName = profileState.profile?.displayName ?? 
        (user != null ? user.email.split('@').first : 'User');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
            tooltip: 'Settings',
          ),
          const SizedBox(width: AppDimensions.spacing8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(documentsProvider.notifier).loadDocuments();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(theme, displayName),

              const SizedBox(height: AppDimensions.spacing32),

              // Quick Actions - Upload and Start Chat
              _buildQuickActionButtons(theme),

              const SizedBox(height: AppDimensions.spacing32),

              // Recent Documents
              _buildRecentDocuments(theme, documentsState),

              const SizedBox(height: AppDimensions.spacing16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme, String displayName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, $displayName!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButtons(ThemeData theme) {
    return Column(
      children: [
        // Upload New Document Button
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => context.go('/upload'),
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Upload New Document'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacing16),
        // Start New Chat Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Navigate to documents to select one for chat
              context.go('/dashboard');
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Start New Chat'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentDocuments(ThemeData theme, DocumentsState documentsState) {
    final recentDocuments = documentsState.documents.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Documents',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (documentsState.documents.length > 10)
              TextButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacing16),
        if (documentsState.isLoading && documentsState.documents.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.paddingLG),
              child: CircularProgressIndicator(),
            ),
          )
        else if (recentDocuments.isEmpty)
          _buildEmptyState(theme)
        else
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: recentDocuments.length,
              separatorBuilder: (context, index) => const SizedBox(width: AppDimensions.spacing12),
              itemBuilder: (context, index) {
                final doc = recentDocuments[index];
                return SizedBox(
                  width: 160,
                  child: _buildDocumentCard(theme, doc),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDocumentCard(ThemeData theme, document) {
    return Card(
      child: InkWell(
        onTap: () {
          // Navigate to chat with this document
          context.go('/chat', extra: {
            'documentId': document.id,
            'title': document.name,
          });
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.picture_as_pdf,
                color: theme.colorScheme.primary,
                size: 32,
              ),
              const SizedBox(height: AppDimensions.spacing8),
              Expanded(
                child: Text(
                  document.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing4),
              Text(
                _formatDocumentDate(document.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDocumentDate(DateTime? date) {
    if (date == null) return 'Recently uploaded';
    
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Uploaded: Today';
    } else if (difference.inDays == 1) {
      return 'Uploaded: Yesterday';
    } else if (difference.inDays < 7) {
      return 'Last viewed: ${difference.inDays}d ago';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return 'Uploaded: ${months[date.month - 1]} ${date.day}';
    }
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Column(
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          Text(
            'No documents yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            'Upload your first document to get started',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          FilledButton.icon(
            onPressed: () => context.go('/upload'),
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Document'),
          ),
        ],
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home
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
