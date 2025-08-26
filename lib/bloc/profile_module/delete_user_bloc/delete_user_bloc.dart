import 'dart:developer';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/graphQL/graphql_service.dart';
import 'package:azan_guru_mobile/graphQL/queries.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'delete_user_event.dart';

part 'delete_user_state.dart';

class DeleteUserBloc extends Bloc<DeleteUserEvent, DeleteUserState> {
  final graphQLService = GraphQLService();

  DeleteUserBloc() : super(DeleteUserInitialState()) {
    on<UserAccountDeleteEvent>(_userAccountDeleteEvent);
  }

  _userAccountDeleteEvent(UserAccountDeleteEvent event, Emitter emit) async {
    emit(DeleteUserLoadingState());
    String userId = user?.id ?? '';
    final result = await graphQLService.performQuery(
      AzanGuruQueries.deleteUser,
      variables: {"id": userId},
    );
    if (result.hasException) {
      debugPrint(
          'graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
      emit(DeleteUserErrorState());
    } else {
      //   MDLQuestionAnswer? mdlQuestionAnswer;
      //   final dataInfo = result.data?["agHelpDesks"];
      //   debugPrint('graphResponse: $dataInfo');
      //   mdlQuestionAnswer = MDLQuestionAnswer.fromJson(dataInfo);
      emit(DeleteUserSuccessState());
    }
  }
}
