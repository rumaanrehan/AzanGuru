part of 'ad_bloc.dart';

/// Base class for all AdBloc events
abstract class AdEvent {}

/// Event to check and update ad status based on current user subscription/purchase state
class CheckAdStatusEvent extends AdEvent {}

/// Event to manually update ad display status (optional, for future use)
class UpdateAdStatusEvent extends AdEvent {
  final bool shouldShowAds;

  UpdateAdStatusEvent({required this.shouldShowAds});
}
