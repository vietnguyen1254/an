import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../state/app_state.dart';

// TODO(subscriptions): before shipping, replace the fake-purchase path below
// with the real one. Needed for that:
//   1. Create auto-renewable subscriptions named exactly `an_premium_monthly`
//      / `an_premium_yearly` in App Store Connect, and matching subscription
//      products in Google Play Console — real prices live there, not in code.
//   2. Once those exist, `IapService.products` stops coming back empty and
//      `isFake` below flips to false automatically — no code change needed,
//      just delete the fake fallback in buy()/restore() once you trust it.
//   3. Add server-side receipt validation (App Store Server API / Play
//      Developer API) — right now a "purchase" only flips local state and
//      syncs the plan_tier string to the backend, nothing verifies the
//      receipt is real.
//   4. Android has no local sandbox like iOS's StoreKit Testing — test it via
//      a signed build on Play Console's internal testing track.

/// Subscription product IDs. These must be created — with this exact string
/// — as auto-renewable subscriptions in App Store Connect and as
/// subscription products in Google Play Console before a real purchase can
/// go through; until then `products` comes back empty and [IapService] uses
/// the fake-purchase fallback (see [IapService.isFake]).
const kMonthlyProductId = 'an_premium_monthly';
const kYearlyProductId = 'an_premium_yearly';
const kProductIds = {kMonthlyProductId, kYearlyProductId};

const _kFakePurchasedTierKey = 'fake_iap_purchased_tier';

PlanTier? planTierForProductId(String id) => switch (id) {
      kMonthlyProductId => PlanTier.monthly,
      kYearlyProductId => PlanTier.yearly,
      _ => null,
    };

enum IapOutcome { success, pending, cancelled, error, restoredNothing }

class IapResult {
  final IapOutcome outcome;
  final PlanTier? tier;
  final String? message;
  const IapResult(this.outcome, {this.tier, this.message});
}

/// Thin wrapper around `in_app_purchase` for the Premium subscription flow:
/// query the store's real products/prices, buy one, and restore purchases
/// made previously (required by App Store review guidelines on every
/// paywall that sells a subscription).
class IapService {
  IapService._();
  static final IapService instance = IapService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  bool available = false;
  List<ProductDetails> products = [];
  Completer<IapResult>? _pending;

  /// True until real store products exist (App Store Connect / Play
  /// Console — see the TODO above) — [buy] and [restore] simulate success
  /// instead of talking to the store, so the whole Premium flow (paywall →
  /// success screen → plan screen → cancel) can be clicked through end to
  /// end with no real payment and no Xcode StoreKit Testing setup. Never
  /// gate this off with a flag that could ship "on" by accident — it turns
  /// itself off the moment real products are found.
  bool get isFake => products.isEmpty;

  Future<void> init() async {
    available = await _iap.isAvailable();
    if (!available) return;

    // iOS: ask StoreKit to show subscription-status/price-change prompts
    // itself rather than the app having to build that UI.
    if (Platform.isIOS) {
      final iosPlatformAddition = _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(_PaymentQueueDelegate());
    }

    final response = await _iap.queryProductDetails(kProductIds);
    if (response.error != null) {
      debugPrint('IapService: queryProductDetails error: ${response.error}');
    }
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('IapService: product IDs not found in store: ${response.notFoundIDs} — '
          'create matching subscription products in App Store Connect / Play Console.');
    }
    products = response.productDetails;

    _sub = _iap.purchaseStream.listen(_onUpdate, onDone: () => _sub?.cancel(), onError: (Object e) {
      debugPrint('IapService: purchase stream error: $e');
    });
  }

  ProductDetails? productFor(String id) {
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<IapResult> buy(String productId) async {
    if (isFake) return _fakeBuy(productId);

    final product = productFor(productId);
    if (product == null) {
      return const IapResult(IapOutcome.error, message: 'Sản phẩm chưa sẵn sàng trên cửa hàng.');
    }
    _pending = Completer<IapResult>();
    final param = PurchaseParam(productDetails: product);
    // Subscriptions on both stores go through buyNonConsumable in this
    // plugin — there's no separate "buy subscription" call.
    final started = await _iap.buyNonConsumable(purchaseParam: param);
    if (!started) {
      _pending = null;
      return const IapResult(IapOutcome.error, message: 'Không thể bắt đầu giao dịch.');
    }
    return _pending!.future;
  }

  Future<IapResult> restore() async {
    if (isFake) return _fakeRestore();

    _pending = Completer<IapResult>();
    // Give the store a moment to report "nothing found" if there's really
    // nothing to restore — restorePurchases() only resolves once it has
    // kicked things off, not once every past purchase has replayed.
    unawaited(_iap.restorePurchases());
    final result = await _pending!.future.timeout(
      const Duration(seconds: 12),
      onTimeout: () => const IapResult(IapOutcome.restoredNothing),
    );
    return result;
  }

  /// Simulates a successful purchase — a short delay (so the button's
  /// loading state is visible, same as a real network round trip) then
  /// success, no payment sheet of any kind. Remembers the tier locally so
  /// [_fakeRestore] has something real to find later.
  Future<IapResult> _fakeBuy(String productId) async {
    final tier = planTierForProductId(productId);
    if (tier == null) {
      return const IapResult(IapOutcome.error, message: 'Không nhận diện được gói.');
    }
    await Future.delayed(const Duration(milliseconds: 700));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFakePurchasedTierKey, _planTierWireForFake(tier));
    debugPrint('IapService: FAKE purchase of $productId — no real payment made.');
    return IapResult(IapOutcome.success, tier: tier);
  }

  Future<IapResult> _fakeRestore() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();
    final wire = prefs.getString(_kFakePurchasedTierKey);
    final tier = switch (wire) {
      'monthly' => PlanTier.monthly,
      'yearly' => PlanTier.yearly,
      _ => null,
    };
    if (tier == null) return const IapResult(IapOutcome.restoredNothing);
    debugPrint('IapService: FAKE restore found a previous fake purchase ($wire).');
    return IapResult(IapOutcome.success, tier: tier);
  }

  static String _planTierWireForFake(PlanTier t) => switch (t) {
        PlanTier.monthly => 'monthly',
        PlanTier.yearly => 'yearly',
        PlanTier.free => 'free',
      };

  void _onUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _complete(IapResult(IapOutcome.pending, tier: planTierForProductId(purchase.productID)));
          break;
        case PurchaseStatus.error:
          _complete(IapResult(IapOutcome.error, message: purchase.error?.message));
          if (purchase.pendingCompletePurchase) _iap.completePurchase(purchase);
          break;
        case PurchaseStatus.canceled:
          _complete(const IapResult(IapOutcome.cancelled));
          if (purchase.pendingCompletePurchase) _iap.completePurchase(purchase);
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final tier = planTierForProductId(purchase.productID);
          if (tier != null) {
            _complete(IapResult(IapOutcome.success, tier: tier));
          }
          if (purchase.pendingCompletePurchase) _iap.completePurchase(purchase);
          break;
      }
    }
  }

  void _complete(IapResult result) {
    if (_pending == null || _pending!.isCompleted) return;
    _pending!.complete(result);
  }

  void dispose() => _sub?.cancel();
}

/// Required on iOS so StoreKit will surface App Store promoted purchases /
/// transactions initiated outside the app; we don't special-case any of it.
class _PaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) => true;

  @override
  bool shouldShowPriceConsent() => false;
}
