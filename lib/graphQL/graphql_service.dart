import 'dart:developer';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/route/app_routes.dart';
import 'package:azan_guru_mobile/service/local_storage/local_storage_keys.dart';
import 'package:azan_guru_mobile/service/local_storage/storage_manager.dart';
import 'package:azan_guru_mobile/ui/common/loader.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:azan_guru_mobile/graphQL/queries.dart';

class GraphQLService {
  String get apiUrl => '${baseUrl}api';
  static final GraphQLService _instance = GraphQLService._internal();
  factory GraphQLService() => _instance;
  late GraphQLClient _client;

  GraphQLService._internal() {
    initClient();
  }

  void initClient({bool addToken = false, bool isMultipart = false}) {
    final HttpLink httpLink = HttpLink(apiUrl);

    final AuthLink authLink = AuthLink(
      getToken: () async {
        final token = StorageManager.instance.getString(LocalStorageKeys.prefAuthToken);
        return token.isNotEmpty ? 'Bearer $token' : null;
      },
    );

    final ErrorLink errorLink = ErrorLink(
      onGraphQLError: (request, forward, response) async* {
        final isUnauthenticated = response?.errors?.any(
              (e) => e.message.toLowerCase().contains('unauthenticated'),
        ) ?? false;

        if (isUnauthenticated) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            final newToken = StorageManager.instance.getString(LocalStorageKeys.prefAuthToken);
            final updatedRequest = request.updateContextEntry<HttpLinkHeaders>(
                  (headers) => HttpLinkHeaders(
                headers: {
                  ...?headers?.headers,
                  'Authorization': 'Bearer $newToken',
                },
              ),
            );
            yield* forward(updatedRequest);
          } else {
            _handleUnauthorized();
          }
        }
      },
    );

    final Link finalLink = errorLink.concat(authLink).concat(httpLink);

    _client = GraphQLClient(
      link: finalLink,
      cache: GraphQLCache(store: HiveStore()),
    );
  }

  Future<bool> _refreshToken() async {
    final refreshToken = StorageManager.instance.getString(LocalStorageKeys.prefRefreshToken);
    if (refreshToken.isEmpty) return false;

    final MutationOptions options = MutationOptions(
      document: gql(AzanGuruQueries.refreshToken),
      variables: {'refreshToken': refreshToken},
    );

    final result = await _client.mutate(options);

    if (result.hasException) return false;

    final tokenData = result.data?['refreshToken'];
    if (tokenData != null && tokenData['authToken'] != null) {
      await StorageManager.instance.setString(LocalStorageKeys.prefAuthToken, tokenData['authToken']);
      await StorageManager.instance.setString(LocalStorageKeys.prefRefreshToken, tokenData['refreshToken']);
      return true;
    }

    return false;
  }

  void _handleUnauthorized() {
    Fluttertoast.showToast(
      msg: 'Session expired. Please log in again.',
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
    StorageManager.instance.setBool(LocalStorageKeys.prefUserLogin, false);
    StorageManager.instance.setString(LocalStorageKeys.prefAuthToken, '');
    StorageManager.instance.clear();
    if (AGLoader.isShown) AGLoader.hide();
    Get.offAllNamed(Routes.login);
  }

  Future<QueryResult> performQuery(
      String query, {
        Map<String, dynamic> variables = const {},
        Object? Function(Map<String, dynamic>)? dataParser,
      }) async {
    debugPrint('Query --- $query');
    debugPrint('Variables --- $variables');
    QueryOptions options = QueryOptions(
      fetchPolicy: FetchPolicy.cacheAndNetwork,
      document: gql(query),
      variables: variables,
      parserFn: dataParser,
    );

    final result = await _client.query(options);
    LinkException? exception = result.exception?.linkException;
    serverStatus(exception);
    return result;
  }

  Future<QueryResult> performMutation(
      String query, {
        Map<String, dynamic> variables = const {},
        Object? Function(Map<String, dynamic>)? dataParser,
      }) async {
    debugPrint('Query --- $query');
    debugPrint('Variables --- $variables');
    MutationOptions options = MutationOptions(
      fetchPolicy: FetchPolicy.cacheAndNetwork,
      document: gql(query),
      variables: variables,
      parserFn: dataParser,
    );

    final result = await _client.mutate(options);
    LinkException? exception = result.exception?.linkException;
    serverStatus(exception);
    return result;
  }

  serverStatus(LinkException? exception) {
    if (exception is ServerException && exception.statusCode == 401) {
      _handleUnauthorized();
    }
  }

  void clearCache() {
    _client.cache.store.reset();
  }
}
