import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/subscription_repository.dart';

/// Subscription state
class SubscriptionState {
  final String plan; // 'free' or 'pro'
  final String? status; // 'active', 'past_due', 'canceled', 'incomplete'
  final DateTime? currentPeriodEnd;
  final bool isLoading;
  final String? error;

  const SubscriptionState({
    this.plan = 'free',
    this.status,
    this.currentPeriodEnd,
    this.isLoading = false,
    this.error,
  });

  SubscriptionState copyWith({
    String? plan,
    String? status,
    DateTime? currentPeriodEnd,
    bool? isLoading,
    String? error,
  }) {
    return SubscriptionState(
      plan: plan ?? this.plan,
      status: status ?? this.status,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Subscription repository provider
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository();
});

/// Subscription provider
final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return SubscriptionNotifier(repository);
});

/// Subscription notifier
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final SubscriptionRepository _repository;

  SubscriptionNotifier(this._repository) : super(const SubscriptionState());

  /// Load subscription for user
  Future<void> loadSubscription(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      AppLogger.info('Loading subscription for user: $userId');

      final subscription = await _repository.getSubscription(userId);
      
      if (subscription != null) {
        state = state.copyWith(
          plan: subscription['plan'] as String? ?? 'free',
          status: subscription['status'] as String?,
          currentPeriodEnd: subscription['current_period_end'] != null
              ? DateTime.parse(subscription['current_period_end'] as String)
              : null,
          isLoading: false,
        );
      } else {
        // No subscription found, default to free
        state = state.copyWith(
          plan: 'free',
          isLoading: false,
        );
      }

      AppLogger.info('Subscription loaded: ${state.plan}');
    } catch (e) {
      AppLogger.error('Error loading subscription', e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load subscription: ${e.toString()}',
      );
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

