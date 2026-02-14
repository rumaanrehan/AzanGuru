import 'dart:developer';

import 'package:azan_guru_mobile/service/local_storage/local_storage_keys.dart';
import 'package:azan_guru_mobile/service/local_storage/storage_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'ad_event.dart';
part 'ad_state.dart';

/// Centralized BLoC for managing ad display state across the entire application
///
/// This BLoC determines whether ads should be shown based on:
/// - User login status
/// - Subscription status
/// - Course purchase status
class AdBloc extends Bloc<AdEvent, AdState> {
  AdBloc() : super(AdInitialState()) {
    on<CheckAdStatusEvent>(_onCheckAdStatus);
    on<UpdateAdStatusEvent>(_onUpdateAdStatus);
  }

  /// Check current subscription/purchase status and emit appropriate state
  Future<void> _onCheckAdStatus(
    CheckAdStatusEvent event,
    Emitter<AdState> emit,
  ) async {
    try {
      log('🎯 AdBloc: Checking ad status...');

      final user = StorageManager.instance.getLoginUser();
      final hasSubscription = StorageManager.instance.getBool(
        LocalStorageKeys.isUserHasSubscription,
      );
      final hasPurchase = StorageManager.instance.getBool(
        LocalStorageKeys.isCoursePurchased,
      );

      log('🎯 User logged in: ${user != null}');
      log('🎯 Has subscription: $hasSubscription');
      log('🎯 Has purchase: $hasPurchase');

      // Hide ads if user is logged in AND has subscription OR purchase
      if (user != null && (hasSubscription || hasPurchase)) {
        log('🎯 AdBloc: Emitting HideAdsState');
        emit(HideAdsState());
      } else {
        log('🎯 AdBloc: Emitting ShowAdsState');
        emit(ShowAdsState());
      }
    } catch (e) {
      log('🚨 AdBloc: Error checking ad status: $e');
      // On error, default to showing ads
      emit(ShowAdsState());
    }
  }

  /// Manually update ad display status (for future use)
  Future<void> _onUpdateAdStatus(
    UpdateAdStatusEvent event,
    Emitter<AdState> emit,
  ) async {
    log('🎯 AdBloc: Manual update - shouldShowAds: ${event.shouldShowAds}');
    if (event.shouldShowAds) {
      emit(ShowAdsState());
    } else {
      emit(HideAdsState());
    }
  }
}
