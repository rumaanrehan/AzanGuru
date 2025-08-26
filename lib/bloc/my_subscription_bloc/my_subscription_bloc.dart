import 'dart:developer';

import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/graphQL/graphql_service.dart';
import 'package:azan_guru_mobile/graphQL/queries.dart';
import 'package:azan_guru_mobile/ui/model/key_value_model.dart';
import 'package:azan_guru_mobile/ui/model/user_order.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

part 'my_subscription_event.dart';
part 'my_subscription_state.dart';

class MySubscriptionBloc
    extends Bloc<MySubscriptionEvent, MySubscriptionState> {
  final graphQLService = GraphQLService();
  MySubscriptionBloc() : super(MySubscriptionInitial()) {
    on<GetMySubscriptionEvent>(_getMySubscription);
  }

  _getMySubscription(GetMySubscriptionEvent event, Emitter emit) async {
    emit(MySubscriptionLoading(isLoading: true));
    graphQLService.initClient(addToken: user != null);
    final result = await graphQLService.performQuery(
      AzanGuruQueries.getOrderStatus,
      variables: {'email': user?.email ?? ''},
    );
    emit(MySubscriptionLoading(isLoading: false));
    if (result.hasException) {
      debugPrint(
          'graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
    } else {
      final dataInfo = result.data?["getSubscriptions"];
      debugPrint('graphResponse: $dataInfo');
      UserOrder order = UserOrder.fromJson(dataInfo);
      bool isPaidUser = false;
      KeyValueModel? orderStatusData = (order.orders
          ?.firstWhereOrNull((element) => element.key == 'status'));
      if (orderStatusData != null) {
        isPaidUser = (orderStatusData.value != null) &&
            (orderStatusData.value == 'completed');
      }
      emit(GetMySubscriptionState(isPaidUser: isPaidUser));
    }
  }
}
