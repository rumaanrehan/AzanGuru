part of 'listen_quran_bloc.dart';

abstract class ListenQuranState {}

final class ListenQuranInitial extends ListenQuranState {}

final class ShowLoadingState extends ListenQuranState {}

final class HideLoadingState extends ListenQuranState {}

final class GetFreeQuranDataState extends ListenQuranState {
  final FreeQuranData? freeQuranData;

  GetFreeQuranDataState({required this.freeQuranData});
}
