import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository.dart';

/// Profile repository provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

/// Profile state
class ProfileState {
  final ProfileModel? profile;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    ProfileModel? profile,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Profile provider
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  final authState = ref.watch(authProvider);
  return ProfileNotifier(repository, authState);
});

/// Profile notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;
  final AuthState _authState;

  ProfileNotifier(this._repository, this._authState) : super(const ProfileState()) {
    _init();
  }

  /// Initialize - load profile if user is authenticated
  void _init() {
    if (_authState.status == AuthStatus.authenticated && _authState.user != null) {
      loadProfile(_authState.user!.id);
    }
  }

  /// Load profile
  Future<void> loadProfile(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      AppLogger.info('Loading profile for user: $userId');

      final profile = await _repository.getProfile(userId);
      
      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );

      AppLogger.info('Profile loaded successfully');
    } catch (e) {
      AppLogger.error('Error loading profile', e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load profile: ${e.toString()}',
      );
    }
  }

  /// Update profile
  Future<bool> updateProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      AppLogger.info('Updating profile');

      final updatedProfile = await _repository.updateProfile(
        userId: userId,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );

      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
      );

      AppLogger.info('Profile updated successfully');
      return true;
    } catch (e) {
      AppLogger.error('Error updating profile', e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update profile: ${e.toString()}',
      );
      return false;
    }
  }

  /// Upload avatar
  Future<String?> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      AppLogger.info('Uploading avatar');

      // Delete old avatar if exists
      if (state.profile?.avatarUrl != null) {
        await _repository.deleteAvatar(state.profile!.avatarUrl!);
      }

      // Upload new avatar
      final avatarUrl = await _repository.uploadAvatar(
        userId: userId,
        imageFile: imageFile,
      );

      // Update profile with new avatar URL
      await updateProfile(
        userId: userId,
        avatarUrl: avatarUrl,
      );

      AppLogger.info('Avatar uploaded successfully');
      return avatarUrl;
    } catch (e) {
      AppLogger.error('Error uploading avatar', e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to upload avatar: ${e.toString()}',
      );
      return null;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
