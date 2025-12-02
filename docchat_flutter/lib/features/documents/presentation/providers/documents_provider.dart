import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/document_repository.dart';
import '../../domain/entities/document.dart';
import '../../domain/repositories/document_repository_interface.dart';

final documentRepositoryProvider = Provider<DocumentRepositoryInterface>((ref) {
  return DocumentRepository();
});

class DocumentsState {
  final List<Document> documents;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final bool isAuthenticated;

  const DocumentsState({
    this.documents = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.isAuthenticated = false,
  });

  DocumentsState copyWith({
    List<Document>? documents,
    bool? isLoading,
    String? error,
    bool? hasMore,
    bool? isAuthenticated,
  }) {
    return DocumentsState(
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class DocumentsNotifier extends StateNotifier<DocumentsState> {
  final DocumentRepositoryInterface _repository;

  DocumentsNotifier(this._repository) : super(const DocumentsState()) {
    _init();
  }

  void _init() {
    final user = SupabaseConfig.currentUser;
    if (user != null) {
      state = state.copyWith(isAuthenticated: true);
      loadDocuments();
    } else {
      state = state.copyWith(isAuthenticated: false, isLoading: false);
    }
  }

  Future<void> loadDocuments() async {
    final user = SupabaseConfig.currentUser;
    if (user == null) {
      state = state.copyWith(isAuthenticated: false, isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, error: null, isAuthenticated: true);

    try {
      final documents = await _repository.listDocuments(limit: 20);
      state = state.copyWith(
        documents: documents,
        isLoading: false,
        hasMore: documents.length >= 20,
      );
      AppLogger.info('Loaded ${documents.length} documents');
    } catch (e) {
      AppLogger.error('Error loading documents', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadDocuments();
  }

  Future<void> uploadDocument() async {
    final user = SupabaseConfig.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final document = await _repository.uploadDocument();
      
      final updatedDocs = [document, ...state.documents];
      state = state.copyWith(
        documents: updatedDocs,
        isLoading: false,
      );
      
      AppLogger.info('Document uploaded: ${document.name}');
    } catch (e) {
      AppLogger.error('Error uploading document', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      await _repository.deleteDocument(documentId);
      
      final updatedDocs = state.documents
          .where((doc) => doc.id != documentId)
          .toList();
      
      state = state.copyWith(documents: updatedDocs);
      AppLogger.info('Document deleted: $documentId');
    } catch (e) {
      AppLogger.error('Error deleting document', e);
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    try {
      final lastDoc = state.documents.isEmpty ? null : state.documents.last;
      if (lastDoc == null) return;

      final moreDocs = await _repository.listDocuments(
        limit: 20,
        startingAfterId: lastDoc.id,
      );

      final updatedDocs = [...state.documents, ...moreDocs];
      state = state.copyWith(
        documents: updatedDocs,
        hasMore: moreDocs.length >= 20,
      );

      AppLogger.info('Loaded ${moreDocs.length} more documents');
    } catch (e) {
      AppLogger.error('Error loading more documents', e);
    }
  }
}

final documentsProvider =
    StateNotifierProvider<DocumentsNotifier, DocumentsState>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return DocumentsNotifier(repository);
});
