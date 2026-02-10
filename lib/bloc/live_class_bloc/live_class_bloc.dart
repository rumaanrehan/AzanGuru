import 'dart:developer';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/graphQL/graphql_service.dart';
import 'package:azan_guru_mobile/graphQL/queries.dart';
import 'package:azan_guru_mobile/ui/model/live_classes_data.dart';
import 'package:azan_guru_mobile/ui/model/user_order.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'live_class_event.dart';

part 'live_class_state.dart';

class LiveClassBloc extends Bloc<LiveClassEvent, LiveClassState> {
  final graphQLService = GraphQLService();

  LiveClassBloc() : super(LiveClassInitial()) {
    on<GetSubscriptionStatusEvent>(_getSubscriptionStatusEvent);

    on<GetLiveClassDataEvent>((event, emit) async {
      Hive.openBox<LiveClassesData>('liveClassesData');

      Box<LiveClassesData> box =
          await Hive.openBox<LiveClassesData>('liveClassesDataBox');
      LiveClassesData? storedData = box.get('liveClassesData');

      if (storedData != null) {
        emit(GetLiveClassDataState(liveClassesData: storedData));
      } else {
        emit(ShowLiveClassLoadingState());
      }

      final result = await graphQLService.performMutation(
        AzanGuruQueries.liveClass,
      );

      emit(HideLiveClassLoadingState());

      if (result.hasException) {
        debugPrint(
            'graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
      } else {
        final catData = result.data?['generalOptions'];
        debugPrint('graphResponse: $catData');
        LiveClassesData? data;
        if (catData != null) {
          data = LiveClassesData.fromJson(catData);
          await box.delete("liveClassesData");
          await box.put('liveClassesData', data);
        }
        emit(GetLiveClassDataState(liveClassesData: data));
      }
    });
  }

  _getSubscriptionStatusEvent(
    GetSubscriptionStatusEvent event,
    Emitter emit,
  ) async {
    graphQLService.initClient();
    // emit(ShowLiveClassLoadingState());
    final result = await graphQLService.performQuery(
      AzanGuruQueries.getOrderStatus,
      variables: {'email': user?.email ?? ''},
    );
    emit(HideLiveClassLoadingState());
    if (result.hasException) {
      debugPrint(
          'graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
    } else {
      final dataInfo = result.data?["getSubscriptions"];
      debugPrint('graphResponse: $dataInfo');
      UserOrder order = UserOrder.fromJson(dataInfo);
      emit(GetSubscriptionStatusState(order));
    }
  }
}
