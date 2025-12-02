import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/profile_model.dart';

/// Profile repository for managing user profiles
class ProfileRepository {
  final SupabaseClient _supabase = SupabaseConfig.client;

  /// Get profile for current user
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      AppLogger.info('Fetching profile for user: $userId');

      final response = await _supabase
          .from(ApiConstants.profilesTable)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        AppLogger.info('No profile found for user: $userId');
        return null;
      }

      return ProfileModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error fetching profile', e);
      throw ServerException('Failed to fetch profile: ${e.toString()}');
    }
  }

  /// Update profile
  Future<ProfileModel> updateProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      AppLogger.info('Updating profile for user: $userId');

      final updates = {
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Remove null values
      updates.removeWhere((key, value) => value == null);

      final response = await _supabase
          .from(ApiConstants.profilesTable)
          .update(updates)
          .eq('user_id', userId)
          .select()
          .single();

      AppLogger.info('Profile updated successfully');
      return ProfileModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error updating profile', e);
      throw ServerException('Failed to update profile: ${e.toString()}');
    }
  }

  /// Create profile (called during signup)
  Future<ProfileModel> createProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      AppLogger.info('Creating profile for user: $userId');

      final now = DateTime.now().toIso8601String();
      final data = {
        'user_id': userId,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'created_at': now,
        'updated_at': now,
      };

      final response = await _supabase
          .from(ApiConstants.profilesTable)
          .insert(data)
          .select()
          .single();

      AppLogger.info('Profile created successfully');
      return ProfileModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error creating profile', e);
      throw ServerException('Failed to create profile: ${e.toString()}');
    }
  }

  /// Upload avatar image
  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      AppLogger.info('Uploading avatar for user: $userId');

      final fileExt = imageFile.path.split('.').last;
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'avatars/$fileName';

      // Upload to Supabase Storage
      await _supabase.storage
          .from('avatars')
          .upload(filePath, imageFile);

      // Get public URL
      final publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

      AppLogger.info('Avatar uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      AppLogger.error('Error uploading avatar', e);
      throw ServerException('Failed to upload avatar: ${e.toString()}');
    }
  }

  /// Delete old avatar
  Future<void> deleteAvatar(String avatarUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(avatarUrl);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.length >= 2) {
        final bucket = pathSegments[pathSegments.length - 2];
        final fileName = pathSegments.last;
        final filePath = 'avatars/$fileName';

        await _supabase.storage
            .from(bucket)
            .remove([filePath]);

        AppLogger.info('Old avatar deleted: $filePath');
      }
    } catch (e) {
      AppLogger.warning('Error deleting old avatar (non-critical)', e);
      // Don't throw - this is non-critical
    }
  }
}
