import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Subscription repository for managing user subscriptions
class SubscriptionRepository {
  final SupabaseClient _supabase = SupabaseConfig.client;

  /// Get subscription for current user
  Future<Map<String, dynamic>?> getSubscription(String userId) async {
    try {
      AppLogger.info('Fetching subscription for user: $userId');

      final response = await _supabase
          .from('subscriptions')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        AppLogger.info('No subscription found for user: $userId');
        return null;
      }

      return Map<String, dynamic>.from(response);
    } catch (e) {
      AppLogger.error('Error fetching subscription', e);
      throw ServerException('Failed to fetch subscription: ${e.toString()}');
    }
  }
}

