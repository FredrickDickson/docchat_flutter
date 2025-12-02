import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/documents_provider.dart';
import 'document_card.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/empty_state.dart';

class DocumentList extends ConsumerWidget {
  const DocumentList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(documentsProvider);
    final notifier = ref.read(documentsProvider.notifier);

    if (!state.isAuthenticated) {
      return EmptyState(
        icon: Icons.login,
        title: 'Please sign in',
        message: 'Sign in to view your documents',
      );
    }

    if (state.isLoading && state.documents.isEmpty) {
      return const Center(child: LoadingIndicator());
    }

    if (state.error != null && state.documents.isEmpty) {
      return ErrorDisplayWidget(
        message: state.error!,
        onRetry: () => notifier.refresh(),
      );
    }

    if (state.documents.isEmpty) {
      return EmptyState(
        icon: Icons.folder_open,
        title: 'No documents yet',
        message: 'Upload your first document to get started',
      );
    }

    return RefreshIndicator(
      onRefresh: () => notifier.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.documents.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.documents.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              notifier.loadMore();
            });
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final document = state.documents[index];
          return DocumentCard(
            document: document,
            onTap: () {
              context.go('/chat', extra: {
                'documentId': document.id,
                'title': document.name,
              });
            },
            onDelete: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Delete Document'),
                  content: Text('Are you sure you want to delete "${document.name}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        notifier.deleteDocument(document.id);
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
