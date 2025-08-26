import 'dart:developer';
import 'package:azan_guru_mobile/graphQL/graphql_service.dart';
import 'package:azan_guru_mobile/graphQL/queries.dart';
import 'package:azan_guru_mobile/ui/model/free_quran_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'listen_quran_event.dart';

part 'listen_quran_state.dart';

class ListenQuranBloc extends Bloc<ListenQuranEvent, ListenQuranState> {
  final graphQLService = GraphQLService();

  ListenQuranBloc() : super(ListenQuranInitial()) {
    on<GetFreeQuranDataEvent>((event, emit) async {
      Hive.openBox<FreeQuranData>('freeQuranData');

      Box<FreeQuranData> box =
          await Hive.openBox<FreeQuranData>('freeQuranDataBox');
      FreeQuranData? storedData = box.get('freeQuranData');

      if (storedData != null) {
        // If data is found in Hive, emit it immediately
        emit(GetFreeQuranDataState(freeQuranData: storedData));
      } else {
        // Show loading state if no data is available in Hive
        emit(ShowLoadingState());
      }

      final result = await graphQLService.performMutation(
        AzanGuruQueries.freeQuranList,
      );

      emit(HideLoadingState());

      if (result.hasException) {
        debugPrint(
            'graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
      } else {
        final catData = result.data?['agListenQurans'];
        FreeQuranData? data;
        if (catData != null) {
          data = FreeQuranData.fromJson(catData);
          await box.delete("freeQuranData");
          await box.put('freeQuranData', data);
          emit(GetFreeQuranDataState(freeQuranData: data));
        }
      }
    });
  }
}
