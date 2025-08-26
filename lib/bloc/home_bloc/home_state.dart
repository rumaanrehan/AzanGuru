part of 'home_bloc.dart';

abstract class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeShowLoadingState extends HomeState {}

final class HomeHideLoadingState extends HomeState {}

final class GetCategoriesState extends HomeState {
  final List<MDLCourseList>? nodes;

  GetCategoriesState(this.nodes);
}
