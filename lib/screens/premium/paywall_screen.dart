import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/iap_service.dart';
import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../widgets/app_button.dart';
import 'payment_success_screen.dart';
import 'premium_copy.dart';

// Shown until the real store price loads (store unavailable, product not yet
// created in App Store Connect / Play Console, or offline).
const _fallbackYearlyPrice = '1.699.000đ';
const _fallbackMonthlyPrice = '199.000đ';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  PlanTier _selected = PlanTier.yearly;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    IapService.instance.init().then((_) {
      if (mounted) setState(() {});
    });
  }

  String _priceFor(PlanTier tier) {
    final id = tier == PlanTier.yearly ? kYearlyProductId : kMonthlyProductId;
    final product = IapService.instance.productFor(id);
    if (product != null) return product.price;
    return tier == PlanTier.yearly
        ? _fallbackYearlyPrice
        : _fallbackMonthlyPrice;
  }

  Future<void> _subscribe() async {
    if (_busy) return;
    setState(() => _busy = true);
    final productId = _selected == PlanTier.yearly
        ? kYearlyProductId
        : kMonthlyProductId;
    final result = await IapService.instance.buy(productId);
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result.outcome) {
      case IapOutcome.success:
        context.read<AppState>().setPlan(result.tier ?? _selected);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PaymentSuccessScreen()),
        );
        break;
      case IapOutcome.pending:
        _showMessage(
          'Giao dịch đang được xử lý. Bạn sẽ thấy Premium mở khoá khi hoàn tất.',
        );
        break;
      case IapOutcome.cancelled:
        break;
      case IapOutcome.error:
      case IapOutcome.restoredNothing:
        _showMessage(
          result.message ?? 'Không thể hoàn tất giao dịch. Vui lòng thử lại.',
        );
        break;
    }
  }

  Future<void> _restore() async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await IapService.instance.restore();
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result.outcome) {
      case IapOutcome.success:
        context.read<AppState>().setPlan(result.tier ?? PlanTier.monthly);
        _showMessage('Đã khôi phục gói Premium của bạn.');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PaymentSuccessScreen()),
        );
        break;
      case IapOutcome.restoredNothing:
        _showMessage('Không tìm thấy giao dịch Premium nào để khôi phục.');
        break;
      case IapOutcome.error:
        _showMessage(result.message ?? 'Không thể khôi phục giao dịch.');
        break;
      case IapOutcome.pending:
      case IapOutcome.cancelled:
        break;
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.premiumDarkC,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 8, 26, 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: const Text(
                      '×',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Scrollable rather than relying on a Spacer to fit everything
              // exactly — the fake-mode banner and any future copy additions
              // must never silently overflow off the bottom of a smaller
              // phone.
              Expanded(child: SingleChildScrollView(child: _body(context))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      children: [
        if (IapService.instance.isFake) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.tan.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.tan.withValues(alpha: 0.5)),
            ),
            child: Text(
              'CHẾ ĐỘ THỬ NGHIỆM — chưa có thanh toán thật, giá và nút bên dưới đều giả lập.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'BeVietnamPro',
                fontWeight: FontWeight.w500,
                fontSize: 12,
                height: 18 / 12,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'AN PREMIUM',
            style: TextStyle(
              fontFamily: 'BeVietnamPro',
              fontSize: 10.5,
              letterSpacing: 1.2,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Mở khoá toàn bộ\nnội dung thiền và chữa lành',
            style: TextStyle(
              fontFamily: 'Lora',
              fontSize: 30,
              height: 39 / 30,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 26),
        ...kPremiumFeatures.map(
          (f) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.premiumMint,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    f,
                    style: TextStyle(
                      fontFamily: 'BeVietnamPro',
                      fontWeight: FontWeight.w300,
                      fontSize: 14.5,
                      height: 23 / 14.5,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _PlanCard(
          title: 'Theo năm',
          price: _priceFor(PlanTier.yearly),
          sub: '≈ 141.500đ mỗi tháng',
          badge: 'TIẾT KIỆM 29%',
          selected: _selected == PlanTier.yearly,
          onTap: () => setState(() => _selected = PlanTier.yearly),
        ),
        const SizedBox(height: 10),
        _PlanCard(
          title: 'Theo tháng',
          price: _priceFor(PlanTier.monthly),
          sub: 'huỷ bất cứ lúc nào',
          selected: _selected == PlanTier.monthly,
          onTap: () => setState(() => _selected = PlanTier.monthly),
        ),
        const SizedBox(height: 28),
        AppButton(
          label: _busy ? 'Đang xử lý…' : 'Nâng cấp Premium',
          variant: AppButtonVariant.light,
          onPressed: _busy ? null : _subscribe,
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _busy ? null : _restore,
          child: Text(
            'Khôi phục mua hàng',
            style: TextStyle(
              fontFamily: 'BeVietnamPro',
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _selected == PlanTier.yearly
              ? 'Tự động gia hạn hàng năm. Huỷ bất cứ lúc nào trong Cài đặt.'
              : 'Tự động gia hạn hàng tháng. Huỷ bất cứ lúc nào trong Cài đặt.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'BeVietnamPro',
            fontWeight: FontWeight.w300,
            fontSize: 11.5,
            height: 18 / 11.5,
            color: Colors.white.withValues(alpha: 0.42),
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String sub;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.sub,
    this.badge,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: selected ? Colors.white.withValues(alpha: 0.07) : null,
              border: Border.all(
                color: selected
                    ? AppColors.premiumMint
                    : Colors.white.withValues(alpha: 0.16),
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'BeVietnamPro',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        price,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 20,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  sub,
                  style: TextStyle(
                    fontFamily: 'BeVietnamPro',
                    fontWeight: FontWeight.w300,
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              right: 18,
              top: -11,
              child: Container(
                height: 22,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.premiumMint,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    fontFamily: 'BeVietnamPro',
                    fontWeight: FontWeight.w600,
                    fontSize: 10.5,
                    letterSpacing: 0.4,
                    color: Color(0xFF1B3B33),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
