import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:http/http.dart' as http;
import '../../common/util.dart';
import '../../service/local_storage/local_storage_keys.dart';
import '../../service/local_storage/storage_manager.dart';
import '../../ui/common/alert/normal_custom_alert.dart';
import '../../ui/model/user.dart';
import 'package:flutter/material.dart';

part 'in_app_purchase_event.dart';

part 'in_app_purchase_state.dart';

class InAppPurchaseBloc extends Bloc<InAppPurchaseEvent, InAppPurchaseState> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  String get token =>
      StorageManager.instance.getString(LocalStorageKeys.prefAuthToken);
  User? get user => StorageManager.instance.getLoginUser()?.user;
  String pendingMessage =
      "Your purchase is currently in pending status. We are processing your order. Once it's confirmed, you will be notified.If you want to complete or cancel this plan manually, Here are steps-\nSettings -> Name -> Media & Purchases -> View Account -> Purchase History.\nOR\n1. Go to reportaproblem.apple.com.\n2. Sign in with your Apple ID and password.\n3. Check your purchase history.";
  InAppPurchaseBloc() : super(InAppPurchaseInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<PurchaseProduct>(_onPurchaseProduct);
    on<PurchaseUpdated>(_onPurchaseUpdated);
    // Listen to the purchase stream
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) async {
      for (var e in purchaseDetailsList) {
        if (e.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(e);
        }
      }
      add(PurchaseUpdated(purchaseDetailsList, 0));
    });
    // _inAppPurchase.restorePurchases();
  }

  Future<void> _onLoadProducts(
      LoadProducts event, Emitter<InAppPurchaseState> emit) async {
    emit(InAppPurchaseLoading());

    try {
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        emit(InAppPurchaseError(message: 'Store not available'));
        return;
      }
      const Set<String> kIds = {'ag_basic_plan', 'ag_subscription_plan'};
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(kIds);

      if (response.notFoundIDs.isNotEmpty) {
        emit(InAppPurchaseError(message: 'Products not found'));
        return;
      }

      emit(InAppPurchaseLoaded(response.productDetails));
    } catch (e) {
      emit(InAppPurchaseError(message: e.toString()));
    }
  }

  Future<void> _onPurchaseProduct(
      PurchaseProduct event, Emitter<InAppPurchaseState> emit) async {
    emit(InAppPurchaseProcessingLoading(true));
    final purchaseParam = PurchaseParam(productDetails: event.product);
    try {
      // Start the purchase process
      event.product.id == 'ag_basic_plan'
          ? await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam)
          : await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      // Listen for purchase updates
      await for (List<PurchaseDetails> purchaseDetailsList
          in _inAppPurchase.purchaseStream) {
        for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
          switch (purchaseDetails.status) {
            case PurchaseStatus.purchased:
            case PurchaseStatus.restored:
            case PurchaseStatus.pending:
              await _handleSuccessfulPurchase(event, purchaseDetails, emit);
              break;
            case PurchaseStatus.error:
              // Reset flag immediately when error occurs
              emit(InAppPurchaseError(
                  message: purchaseDetails.error?.message ?? "Unknown error"));
              return;
            case PurchaseStatus.canceled:
              // Reset flag when purchase is canceled
              emit(InAppPurchaseError(message: "Purchase was canceled."));
              return;
          }
          return;
        }
      }
    } catch (e) {
      print('reached at catch===>');
      // Show pending dialog only after resetting the flag
      if (e is PlatformException) {
        if (e.code == "storekit_duplicate_product_object") {
          NormalCustomAlert.showAlert2(
            pendingMessage,
            btnFirst: "Cancel",
            onTap: () {
              Get.back();
            },
            barrierDismissible: true,
          );
        }
      }
    } finally {
      emit(InAppPurchaseProcessingLoading(false));
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseProduct event,
      PurchaseDetails purchaseDetails, Emitter<InAppPurchaseState> emit) async {
    try {
      final url =
          Uri.parse('${baseUrl}wp-json/azanguru/v1/ag-update-user-details');

      // Prepare the request body with null-safe values
      final body = jsonEncode({
        'user_id': event.userId ?? 0,
        'course_id': event.courseId ?? '',
        'order_id': purchaseDetails.purchaseID ?? '',
        'product_id': purchaseDetails.productID ?? '',
        'is_sub_renewing': purchaseDetails.status.name,
      });
      // Set headers
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Emit loading state before the request
      emit(PurchaseLoadingState(true));

      // Make the POST request
      final response = await http.post(url, headers: headers, body: body);

      // Emit loading state after receiving the response
      emit(PurchaseLoadingState(false));

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      // Check the response status
      if (response.statusCode == 200) {
        // Try parsing the response body to JSON
        // final responseBody = jsonDecode(response.body);
        final successMessage = /*responseBody['message'] ?? */
            'Purchase successful!';
        // emit(PurchaseSuccessState(successMessage));
        emit(PurchaseSuccessState(response.body));
      } else {
        // Log the error response for debugging
        debugPrint('Error response body: ${response.body}');
        emit(PurchaseErrorState(
            errorMessage: "Purchase failed. Please try again."));
      }
    } catch (e) {
      // Catch any errors and emit an error state
      debugPrint("Exception caught: $e");
      emit(PurchaseErrorState(errorMessage: "Error occurred: $e"));
    } finally {
      // Always complete the purchase regardless of success or failure
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  Future<void> _handlePurchaseUpdate(PurchaseUpdated event,
      PurchaseDetails purchaseDetails, Emitter<InAppPurchaseState> emit) async {
    try {
      final url =
          Uri.parse('${baseUrl}wp-json/azanguru/v1/ag-update-user-details');

      // Prepare the request body with null-safe values
      final body = jsonEncode({
        'user_id': user?.databaseId ?? 0,
        'course_id': event.courseId ?? '',
        'order_id': purchaseDetails.purchaseID ?? '',
        'product_id': purchaseDetails.productID ?? '',
        'is_sub_renewing': purchaseDetails.status.name,
      });

      print('body====> 2  $body');
      // Set headers
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      emit(PurchaseLoadingState(true));
      // Make the POST request
      print('headers====> 2  $headers');
      final response = await http.post(url, headers: headers, body: body);

      print('response====> 2  $response');

      // Emit loading state after receiving the response
      emit(PurchaseLoadingState(false));
      if (response.statusCode == 200) {
        // Try parsing the response body to JSON
        // final responseBody = jsonDecode(response.body);
        // emit(PurchaseSuccessState(successMessage));
        emit(PurchaseSuccessState(response.body));
      } else {
        // Log the error response for debugging
        debugPrint('Error response body: ${response.body}');
        emit(PurchaseErrorState(
            errorMessage: "Purchase failed. Please try again."));
      }
    } catch (e) {
      // Catch any errors and emit an error state
      debugPrint("Exception caught: $e");
      emit(PurchaseErrorState(errorMessage: "Error occurred: $e"));
    } finally {
      await _inAppPurchase.completePurchase(
          purchaseDetails); // Ensure this is called after API success
    }
  }

  Future<void> _onPurchaseUpdated(
      PurchaseUpdated event, Emitter<InAppPurchaseState> emit) async {
    for (PurchaseDetails purchaseDetails in event.purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored ||
          purchaseDetails.status == PurchaseStatus.pending) {
        await _handlePurchaseUpdate(event, purchaseDetails, emit);
      } else {
        debugPrint('purchaseDetails.status ${purchaseDetails.status}');
      }
    }
  }

  @override
  Future<void> close() {
    _inAppPurchase.purchaseStream.listen((purchaseDetailsList) {
      add(PurchaseUpdated(purchaseDetailsList, 0));
    });
    _subscription.cancel();
    return super.close();
  }
}
