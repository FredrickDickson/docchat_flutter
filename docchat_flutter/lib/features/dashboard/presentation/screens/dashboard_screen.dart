import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/theme_toggle_widget.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../documents/presentation/providers/documents_provider.dart';
import '../../../documents/presentation/widgets/document_list.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentNavIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Documents'),
        actions: [
          const ThemeToggleWidget(),
          const SizedBox(width: AppDimensions.spacing8),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
            },
            tooltip: 'Sign Out',
          ),
          const SizedBox(width: AppDimensions.spacing8),
        ],
      ),
      body: const DocumentList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleUpload(),
        tooltip: 'Upload Document',
        child: const Icon(Icons.add),
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
        break;
      case 2:
        context.go('/upload');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }

  Future<void> _handleUpload() async {
    try {
      await ref.read(documentsProvider.notifier).uploadDocument();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
