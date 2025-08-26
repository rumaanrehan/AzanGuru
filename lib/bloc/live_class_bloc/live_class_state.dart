part of 'live_class_bloc.dart';

abstract class LiveClassState {}

final class LiveClassInitial extends LiveClassState {}

final class ShowLiveClassLoadingState extends LiveClassState {}

final class HideLiveClassLoadingState extends LiveClassState {}

final class GetLiveClassDataState extends LiveClassState {
  final LiveClassesData? liveClassesData;

  GetLiveClassDataState({required this.liveClassesData});
}

final class GetSubscriptionStatusState extends LiveClassState {
  final UserOrder order;

  GetSubscriptionStatusState(this.order);
}
