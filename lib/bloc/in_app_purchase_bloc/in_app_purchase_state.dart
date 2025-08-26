part of 'in_app_purchase_bloc.dart';

abstract class InAppPurchaseState {}

final class InAppPurchaseInitial extends InAppPurchaseState {}

class InAppPurchaseLoading extends InAppPurchaseState {}

class InAppPurchaseProcessing extends InAppPurchaseState {}

class InAppPurchaseProcessingLoading extends InAppPurchaseState {
  bool? isLoading;
  InAppPurchaseProcessingLoading(this.isLoading);
}

class InAppPurchaseLoaded extends InAppPurchaseState {
  final List<ProductDetails> products;

  InAppPurchaseLoaded(this.products);
}

class InAppPurchaseError extends InAppPurchaseState {
  final String message;
  final bool? showCancelButton;
  InAppPurchaseError({required this.message, this.showCancelButton = false});
}

class PurchaseSuccess extends InAppPurchaseState {
  final PurchaseDetails purchaseDetails;

  PurchaseSuccess(this.purchaseDetails);
}

class PurchaseLoadingState extends InAppPurchaseState {
  bool? loading;
  PurchaseLoadingState(this.loading);
}

class PurchaseErrorState extends InAppPurchaseState {
  final String? errorMessage;

  PurchaseErrorState({this.errorMessage});
}

class PurchaseSuccessState extends InAppPurchaseState {
  final String? successMessage;
  PurchaseSuccessState(this.successMessage);
}
