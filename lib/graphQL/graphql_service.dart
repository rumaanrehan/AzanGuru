import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/service/local_storage/local_storage_keys.dart';
import 'package:azan_guru_mobile/service/local_storage/storage_manager.dart';
import 'package:azan_guru_mobile/ui/common/loader.dart';

class GraphQLService {
  String get apiUrl => '${baseUrl}api';

  static final GraphQLService _instance = GraphQLService._internal();
  factory GraphQLService() => _instance;

  late GraphQLClient _client;

  GraphQLService._internal() {
    initClient();
  }

  /// Call this AFTER saving JWT
  void initClient() {
    final httpLink = HttpLink(apiUrl);

    final authLink = AuthLink(
      getToken: () async {
        final token = StorageManager.instance
            .getString(LocalStorageKeys.prefAuthToken);
        if (token.isEmpty) return null;
        return 'Bearer $token';
      },
    );

    final errorLink = ErrorLink(
      onGraphQLError: (request, forward, response) async* {
        final unauthenticated = response?.errors?.any(
              (e) => e.message.toLowerCase().contains('unauthenticated'),
        ) ?? false;

        if (unauthenticated) {
          _handleUnauthorized();
        }
      },
    );

    final link = errorLink.concat(authLink).concat(httpLink);

    _client = GraphQLClient(
      link: link,
      cache: GraphQLCache(store: HiveStore()),
    );
  }

  /// SAFE cache reset
  void clearCache() {
    try {
      _client.cache.store.reset();
    } catch (_) {}
  }

  Future<QueryResult> performQuery(
      String query, {
        Map<String, dynamic> variables = const {},
      }) async {
    return await _client.query(
      QueryOptions(
        document: gql(query),
        variables: variables,
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );
  }

  Future<QueryResult> performMutation(
      String query, {
        Map<String, dynamic> variables = const {},
      }) async {
    return await _client.mutate(
      MutationOptions(
        document: gql(query),
        variables: variables,
      ),
    );
  }

  void _handleUnauthorized() {
    StorageManager.instance.clear();

    if (AGLoader.isShown) {
      AGLoader.hide();
    }

    Fluttertoast.showToast(
      msg: 'Session expired. Please login again.',
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );

    Get.offAllNamed(Routes.login);
  }
}

