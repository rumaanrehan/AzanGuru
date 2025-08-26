part of 'my_subscription_bloc.dart';

abstract class MySubscriptionState {}

final class MySubscriptionInitial extends MySubscriptionState {}

final class MySubscriptionLoading extends MySubscriptionState {
  final bool isLoading;

  MySubscriptionLoading({required this.isLoading});
}

final class GetMySubscriptionState extends MySubscriptionState {
  final bool isPaidUser;

  GetMySubscriptionState({required this.isPaidUser});
}
