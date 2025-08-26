part of 'help_bloc.dart';

@immutable
abstract class HelpState {}

final class MenuInitial extends HelpState {}

final class GetOrderStatusState extends HelpState {
  final UserOrder order;

  GetOrderStatusState(this.order);
}

class ShowLoaderState extends HelpState {}

class HideLoaderState extends HelpState {}
