import 'dart:developer';

import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/graphQL/graphql_service.dart';
import 'package:azan_guru_mobile/graphQL/queries.dart';
import 'package:azan_guru_mobile/ui/model/user_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'help_event.dart';
part 'help_state.dart';

class HelpBloc extends Bloc<HelpEvent, HelpState> {
  final GraphQLService graphQLService = GraphQLService();
  HelpBloc() : super(MenuInitial()) {
    on<GetOrderStatusEvent>(_getOrderStatusEvent);
  }

  _getOrderStatusEvent(GetOrderStatusEvent event, Emitter emit) async {
    graphQLService.initClient(addToken: user != null);
    emit(ShowLoaderState());
    final result = await graphQLService.performQuery(
      AzanGuruQueries.getOrderStatus,
      variables: {'email': user?.email ?? ''},
    );
    emit(HideLoaderState());
    if (result.hasException) {
      debugPrint(
          'graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
    } else {
      final dataInfo = result.data?["getSubscriptions"];
      debugPrint('graphResponse: $dataInfo');
      UserOrder order = UserOrder.fromJson(dataInfo);
      emit(GetOrderStatusState(order));
    }
  }
}
