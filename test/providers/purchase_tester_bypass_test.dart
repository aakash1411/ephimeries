import 'dart:async';

import 'package:ephimeries/data/services/iap_service.dart';
import 'package:ephimeries/domain/models/app_settings.dart';
import 'package:ephimeries/providers/purchase_provider.dart';
import 'package:ephimeries/providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class _FakeIapService implements IapService {
  final _stream = StreamController<List<PurchaseDetails>>.broadcast();

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<List<ProductDetails>> fetchProducts() async => const [];

  @override
  Future<void> buy(ProductDetails product) async {}

  @override
  Future<void> restorePurchases() async {}

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _stream.stream;

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {}
}

/// In-memory `Notifier<AppSettings>` substitute used by the IAP tests
/// so we don't have to wire Hive into unit tests. Override every mutator
/// `PurchaseNotifier` may invoke.
class _MemorySettingsNotifier extends Notifier<AppSettings>
    implements SettingsNotifier {
  @override
  AppSettings build() => AppSettings();

  @override
  Future<void> setAnalysisEntitled(bool v) async {
    state = state.copyWith(analysisEntitled: v);
  }

  @override
  Future<void> setAcceptedLegalVersion(int v) async {
    state = state.copyWith(acceptedLegalVersion: v);
  }

  // The remaining setters are not exercised by the tests in this file;
  // throw so that any unexpected coupling is caught loudly.
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  group('redeemTesterCode', () {
    ProviderContainer makeContainer() {
      return ProviderContainer(
        overrides: [
          settingsProvider.overrideWith(_MemorySettingsNotifier.new),
          iapServiceProvider.overrideWithValue(_FakeIapService()),
        ],
      );
    }

    test('correct code grants entitlement and persists in settings',
        () async {
      final container = makeContainer();
      addTearDown(container.dispose);
      expect(container.read(purchaseProvider).entitled, isFalse);

      final ok = await container
          .read(purchaseProvider.notifier)
          .redeemTesterCode(IapService.kTesterBypassCode);
      expect(ok, isTrue);
      expect(container.read(purchaseProvider).entitled, isTrue);
      expect(container.read(settingsProvider).analysisEntitled, isTrue);
    });

    test('wrong code is rejected and entitlement stays off', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      final ok = await container
          .read(purchaseProvider.notifier)
          .redeemTesterCode('WRONG-CODE');
      expect(ok, isFalse);
      expect(container.read(purchaseProvider).entitled, isFalse);
      expect(container.read(purchaseProvider).error, isNotNull);
    });

    test('case-insensitive', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      final ok = await container
          .read(purchaseProvider.notifier)
          .redeemTesterCode(IapService.kTesterBypassCode.toLowerCase());
      expect(ok, isTrue);
    });
  });
}
