part of 'in_app_purchase_bloc.dart';

abstract class InAppPurchaseEvent {}

class LoadProducts extends InAppPurchaseEvent {}

class PurchaseProduct extends InAppPurchaseEvent {
  final ProductDetails product;
  final int? userId;
  final String? courseId;

  PurchaseProduct(this.product, this.userId, this.courseId, );
}

class PurchaseUpdated extends InAppPurchaseEvent {
  final List<PurchaseDetails> purchaseDetailsList;
  final int? courseId;

  PurchaseUpdated(this.purchaseDetailsList,this.courseId);
}
