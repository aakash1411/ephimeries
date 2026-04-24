import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

/// Wrapper around `package:in_app_purchase` exposing the single non-
/// consumable Pro Analysis product.
///
/// The implementation is intentionally thin: callers (Riverpod
/// notifiers) own the entitlement state. This class owns only the
/// StoreKit plumbing.
class IapService {
  IapService({InAppPurchase? plugin})
      : _plugin = plugin ?? InAppPurchase.instance;

  final InAppPurchase _plugin;

  /// App Store / Play Store product identifier for the one-time
  /// non-consumable Pro Analysis unlock. Keep this in sync with the
  /// product configured in App Store Connect.
  static const String kProAnalysisProductId = 'com.ephimeries.pro_analysis';

  /// Tester-bypass code used by reviewers and beta testers. Disclosed
  /// to Apple in the App Review notes so reviewers can evaluate the
  /// gated Analysis tab without making a real purchase. Not a secret;
  /// the gate's purpose is purely UX, not security.
  ///
  /// Rotate per release if leaks become a concern.
  static const String kTesterBypassCode = 'EPHI-DEV-2026';

  /// Whether the user's device can perform StoreKit purchases at all
  /// (off in some MDM configurations or family-sharing restrictions).
  Future<bool> isAvailable() => _plugin.isAvailable();

  /// Fetch the Pro Analysis product metadata (title, localised price,
  /// store currency). Empty if the product is misconfigured or the
  /// device is offline.
  Future<List<ProductDetails>> fetchProducts() async {
    final response =
        await _plugin.queryProductDetails({kProAnalysisProductId});
    return response.productDetails;
  }

  /// Initiate a non-consumable purchase. The result arrives on
  /// [purchaseStream]; this method only kicks off the platform UI.
  Future<void> buy(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    await _plugin.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Restore prior purchases on a fresh install or new device. Results
  /// flow through [purchaseStream] as a `PurchaseStatus.restored`
  /// event.
  Future<void> restorePurchases() => _plugin.restorePurchases();

  /// Stream of all purchase updates (purchased, error, canceled,
  /// pending, restored). Listeners must call [completePurchase] for
  /// every non-pending status they finish handling.
  Stream<List<PurchaseDetails>> get purchaseStream => _plugin.purchaseStream;

  /// Tell StoreKit we are done with this purchase. Required to remove
  /// it from the platform queue.
  Future<void> completePurchase(PurchaseDetails purchase) =>
      _plugin.completePurchase(purchase);
}
