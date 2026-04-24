import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../data/services/iap_service.dart';
import 'settings_provider.dart';

/// Snapshot consumed by paywall / analysis-gate UI.
class PurchaseState {
  const PurchaseState({
    required this.entitled,
    required this.isAvailable,
    required this.product,
    required this.busy,
    this.error,
  });

  /// True when the user has purchased Pro Analysis or redeemed a tester
  /// code. Mirrors `AppSettings.analysisEntitled` plus the live store
  /// state.
  final bool entitled;

  /// Whether StoreKit reports purchases are possible on this device.
  /// `false` on devices where parental controls / MDM restrict IAP.
  final bool isAvailable;

  /// Product details fetched from the store, or null if not yet loaded.
  final ProductDetails? product;

  /// True while a buy / restore round-trip is in flight. Drives the
  /// paywall's spinner and disables buttons.
  final bool busy;

  /// Last user-visible error, if any.
  final String? error;

  PurchaseState copyWith({
    bool? entitled,
    bool? isAvailable,
    ProductDetails? product,
    bool? busy,
    String? error,
    bool clearError = false,
  }) =>
      PurchaseState(
        entitled: entitled ?? this.entitled,
        isAvailable: isAvailable ?? this.isAvailable,
        product: product ?? this.product,
        busy: busy ?? this.busy,
        error: clearError ? null : (error ?? this.error),
      );

  static const initial = PurchaseState(
    entitled: false,
    isAvailable: false,
    product: null,
    busy: false,
  );
}

/// Singleton-scoped IAP service. Tests override this provider with a fake.
final iapServiceProvider = Provider<IapService>((_) => IapService());

/// Reactive purchase + entitlement notifier.
///
/// Sources of entitlement (from highest priority to lowest):
///  1. **Tester bypass code** redeemed in the paywall flow.
///  2. A successful StoreKit purchase observed in [purchaseStream].
///  3. A `PurchaseStatus.restored` event during `restore()`.
///  4. The persisted `AppSettings.analysisEntitled` flag (pre-existing
///     entitlement on this install).
///
/// The notifier writes back to `AppSettings` so the entitlement is durable
/// across launches, and listens to the platform purchase stream for the
/// life of the provider.
class PurchaseNotifier extends Notifier<PurchaseState> {
  StreamSubscription<List<PurchaseDetails>>? _sub;

  @override
  PurchaseState build() {
    final settings = ref.watch(settingsProvider);
    final state = PurchaseState.initial.copyWith(
      entitled: settings.analysisEntitled,
    );
    // Listen for store events for as long as this provider is alive.
    final svc = ref.read(iapServiceProvider);
    _sub = svc.purchaseStream.listen(_onPurchaseUpdate);
    ref.onDispose(() => _sub?.cancel());
    // Best-effort: fetch availability + product details lazily.
    _bootstrap(svc);
    return state;
  }

  Future<void> _bootstrap(IapService svc) async {
    final available = await svc.isAvailable();
    if (!available) {
      state = state.copyWith(isAvailable: false);
      return;
    }
    final products = await svc.fetchProducts();
    state = state.copyWith(
      isAvailable: true,
      product: products.isNotEmpty ? products.first : null,
    );
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> events) async {
    final svc = ref.read(iapServiceProvider);
    for (final p in events) {
      switch (p.status) {
        case PurchaseStatus.pending:
          state = state.copyWith(busy: true, clearError: true);
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // The plugin already enforces that productID matches what we
          // requested; treat any successful event for our product as
          // entitlement.
          if (p.productID == IapService.kProAnalysisProductId) {
            await _grantEntitlement();
          }
        case PurchaseStatus.error:
          state = state.copyWith(
            busy: false,
            error: p.error?.message ?? 'Purchase failed.',
          );
        case PurchaseStatus.canceled:
          state = state.copyWith(busy: false, clearError: true);
      }
      if (p.pendingCompletePurchase) {
        await svc.completePurchase(p);
      }
    }
  }

  Future<void> _grantEntitlement() async {
    await ref.read(settingsProvider.notifier).setAnalysisEntitled(true);
    state = state.copyWith(
      entitled: true,
      busy: false,
      clearError: true,
    );
  }

  /// Initiate a real StoreKit purchase.
  Future<void> purchase() async {
    final svc = ref.read(iapServiceProvider);
    final product = state.product;
    if (product == null) {
      state = state.copyWith(error: 'Product not available right now.');
      return;
    }
    state = state.copyWith(busy: true, clearError: true);
    try {
      await svc.buy(product);
    } catch (e) {
      state = state.copyWith(busy: false, error: e.toString());
    }
  }

  /// Trigger a restore round-trip. The actual entitlement flip happens
  /// when [purchaseStream] delivers a `PurchaseStatus.restored` event.
  Future<void> restore() async {
    final svc = ref.read(iapServiceProvider);
    state = state.copyWith(busy: true, clearError: true);
    try {
      await svc.restorePurchases();
      // No restored event will arrive if there is nothing to restore;
      // clear the spinner after a short window.
      await Future<void>.delayed(const Duration(seconds: 2));
      state = state.copyWith(busy: false);
    } catch (e) {
      state = state.copyWith(busy: false, error: e.toString());
    }
  }

  /// Tester-bypass: matches the entered code (case-insensitive) against
  /// [IapService.kTesterBypassCode]. Returns `true` on a successful
  /// redemption. Disclosed to Apple in App Review notes.
  Future<bool> redeemTesterCode(String code) async {
    if (code.trim().toUpperCase() ==
        IapService.kTesterBypassCode.toUpperCase()) {
      await _grantEntitlement();
      return true;
    }
    state = state.copyWith(error: 'Code not recognised.');
    return false;
  }

  /// Used by Settings → "Reset entitlement" (available only in tester
  /// builds) so testers can re-test the paywall flow without
  /// reinstalling.
  Future<void> resetForTester() async {
    await ref.read(settingsProvider.notifier).setAnalysisEntitled(false);
    state = state.copyWith(entitled: false, clearError: true);
  }
}

final purchaseProvider =
    NotifierProvider<PurchaseNotifier, PurchaseState>(PurchaseNotifier.new);
