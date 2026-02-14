part of 'ad_bloc.dart';

/// Base class for all AdBloc states
abstract class AdState {}

/// Initial state before first ad status check
class AdInitialState extends AdState {}

/// State indicating ads should be shown (user not subscribed/purchased)
class ShowAdsState extends AdState {}

/// State indicating ads should be hidden (user has subscription or purchase)
class HideAdsState extends AdState {}
