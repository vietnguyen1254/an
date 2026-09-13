import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../utils/vn_date.dart';
import '../../widgets/app_button.dart';
import '../../widgets/basics.dart';
import 'paywall_screen.dart';
import 'premium_copy.dart';

const _freeFeatures = ['Theo dõi cảm xúc mỗi ngày', 'Bài tập thở cùng Mây', 'Góc nhìn hôm nay', 'Một bài thiền: Buông một ngày dài'];

// Apple/Google require every auto-renewable subscription to be cancellable
// through the store's own subscription-management screen — an app cannot
// cancel it directly via API, so this always hands off there.
const _iosManageSubscriptionsUrl = 'https://apps.apple.com/account/subscriptions';
const _androidPackageName = 'com.an.an';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final plan = state.plan;

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Text('Quay lại', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 14, color: AppColors.ink.withValues(alpha: 0.5))),
              ),
              const SizedBox(height: 22),
              const Text('Gói của bạn', style: TextStyle(fontFamily: 'Lora', fontSize: 27, color: AppColors.ink)),
              if (plan == PlanTier.free) ..._freeBody(context),
              if (plan == PlanTier.monthly) ..._monthlyBody(context, state),
              if (plan == PlanTier.yearly) ..._yearlyBody(context, state),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _freeBody(BuildContext context) {
    return [
      const SizedBox(height: 18),
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ĐANG DÙNG', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 10.5, letterSpacing: 1, color: AppColors.ink.withValues(alpha: 0.45))),
            const SizedBox(height: 8),
            const Text('An Free', style: TextStyle(fontFamily: 'Lora', fontSize: 22, color: AppColors.ink)),
            const SizedBox(height: 16),
            ..._freeFeatures.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(children: [
                    Container(width: 5, height: 5, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.sage)),
                    const SizedBox(width: 10),
                    Text(f, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13.5, color: AppColors.ink.withValues(alpha: 0.7))),
                  ]),
                )),
          ],
        ),
      ),
      const SizedBox(height: 14),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [AppColors.premiumDarkA, AppColors.premiumDarkB])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CÒN KHOÁ', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 10.5, letterSpacing: 1, color: Colors.white.withValues(alpha: 0.5))),
            const SizedBox(height: 8),
            const Text('Toàn bộ bài thiền dẫn bởi Justin và Trâm, chuỗi bài theo chủ đề, nghe không giới hạn.', style: TextStyle(fontFamily: 'Lora', fontSize: 21, height: 29 / 21, color: Colors.white)),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaywallScreen())),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.18))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Theo tháng', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 12, color: Colors.white.withValues(alpha: 0.55))),
                        const SizedBox(height: 4),
                        const Text('199.000đ', style: TextStyle(fontFamily: 'Lora', fontSize: 17, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaywallScreen())),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.premiumMint, width: 2), color: Colors.white.withValues(alpha: 0.07)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Theo năm · -29%', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 12, color: Colors.white.withValues(alpha: 0.6))),
                        const SizedBox(height: 4),
                        const Text('1.699.000đ', style: TextStyle(fontFamily: 'Lora', fontSize: 17, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
      const SizedBox(height: 20),
      AppButton(label: 'Nâng cấp Premium', onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaywallScreen()))),
      const SizedBox(height: 12),
      Text('Tự động gia hạn theo gói bạn chọn. Huỷ bất cứ lúc nào.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 11.5, color: AppColors.ink.withValues(alpha: 0.45))),
    ];
  }

  Widget _benefitsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('QUYỀN LỢI CỦA BẠN', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 10.5, letterSpacing: 1, color: AppColors.ink.withValues(alpha: 0.45))),
          const SizedBox(height: 14),
          ...kPremiumFeatures.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(width: 5, height: 5, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.sage)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(f, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13.5, height: 20 / 13.5, color: AppColors.ink.withValues(alpha: 0.7)))),
                ]),
              )),
        ],
      ),
    );
  }

  List<Widget> _monthlyBody(BuildContext context, AppState state) {
    final renewsAt = state.planRenewsAt;
    return [
      const SizedBox(height: 18),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [AppColors.premiumDarkA, AppColors.premiumDarkB])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ĐANG HOẠT ĐỘNG', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 10.5, letterSpacing: 1, color: Colors.white.withValues(alpha: 0.5))),
            const SizedBox(height: 8),
            const Text('An Premium · theo tháng', style: TextStyle(fontFamily: 'Lora', fontSize: 22, color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              renewsAt != null ? '199.000đ · gia hạn ${formatShortDate(renewsAt)}' : '199.000đ mỗi tháng',
              style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13, color: Colors.white.withValues(alpha: 0.55)),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.sage.withValues(alpha: 0.12), border: Border.all(color: AppColors.sage.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Đổi sang gói năm', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.ink)),
              Container(
                height: 22,
                padding: const EdgeInsets.symmetric(horizontal: 9),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.sage, borderRadius: BorderRadius.circular(11)),
                child: const Text('-29%', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w600, fontSize: 10.5, color: Colors.white)),
              ),
            ]),
            const SizedBox(height: 8),
            Text('1.699.000đ mỗi năm, tính ra 141.500đ một tháng.', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13, height: 22 / 13, color: AppColors.ink.withValues(alpha: 0.65))),
            const SizedBox(height: 16),
            AppButton(label: 'Đổi sang gói năm', variant: AppButtonVariant.sage, height: 48, onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaywallScreen()))),
          ],
        ),
      ),
      const SizedBox(height: 14),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
        clipBehavior: Clip.hardEdge,
        child: const Column(children: [
          AppListRow(title: 'Phương thức thanh toán', detail: 'Apple ID', isLast: true),
        ]),
      ),
      const SizedBox(height: 14),
      _benefitsCard(),
      const SizedBox(height: 20),
      _CancelButton(state: state, benefits: kPremiumFeatures),
    ];
  }

  List<Widget> _yearlyBody(BuildContext context, AppState state) {
    final renewsAt = state.planRenewsAt;
    return [
      const SizedBox(height: 18),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [AppColors.premiumDarkA, AppColors.premiumDarkB])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ĐANG HOẠT ĐỘNG', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 10.5, letterSpacing: 1, color: Colors.white.withValues(alpha: 0.5))),
            const SizedBox(height: 8),
            const Text('An Premium · theo năm', style: TextStyle(fontFamily: 'Lora', fontSize: 22, color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              renewsAt != null ? '1.699.000đ · gia hạn ${formatShortDate(renewsAt)}' : '1.699.000đ mỗi năm',
              style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13, color: Colors.white.withValues(alpha: 0.55)),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
        clipBehavior: Clip.hardEdge,
        child: const Column(children: [
          AppListRow(title: 'Phương thức thanh toán', detail: 'Apple ID', isLast: true),
        ]),
      ),
      const SizedBox(height: 14),
      _benefitsCard(),
      const SizedBox(height: 20),
      _CancelButton(state: state, benefits: kPremiumFeatures),
    ];
  }
}

/// Big, deliberately sober — a muted brick red rather than the app's usual
/// sage/mint, and a confirmation step first, so cancelling reads as a
/// considered decision rather than a casual tap.
class _CancelButton extends StatelessWidget {
  final AppState state;
  final List<String> benefits;
  const _CancelButton({required this.state, required this.benefits});

  Future<void> _openStoreManagement(BuildContext context) async {
    final uri = Platform.isIOS
        ? Uri.parse(_iosManageSubscriptionsUrl)
        : Uri.parse('https://play.google.com/store/account/subscriptions?package=$_androidPackageName');
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở trang quản lý gói đăng ký.')),
      );
    }
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Huỷ gia hạn Premium?', style: TextStyle(fontFamily: 'Lora', fontSize: 20, color: AppColors.ink)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.planRenewsAt != null
                  ? 'Gói hiện tại vẫn hoạt động đến hết ngày ${formatShortDate(state.planRenewsAt!)}. Sau đó bạn sẽ mất quyền truy cập:'
                  : 'Khi hết chu kỳ hiện tại, bạn sẽ mất quyền truy cập:',
              style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13.5, height: 22 / 13.5, color: AppColors.ink.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 10),
            ...benefits.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('–  ', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 13, color: AppColors.danger)),
                    Expanded(child: Text(f, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w400, fontSize: 13, height: 19 / 13, color: AppColors.ink.withValues(alpha: 0.75)))),
                  ]),
                )),
            const SizedBox(height: 4),
            Text(
              'Bạn sẽ được chuyển đến ${Platform.isIOS ? "App Store" : "Google Play"} để huỷ.',
              style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13.5, height: 22 / 13.5, color: AppColors.ink.withValues(alpha: 0.7)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Giữ gói', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 14, color: AppColors.ink.withValues(alpha: 0.5))),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Tiếp tục huỷ', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) await _openStoreManagement(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: 'Huỷ gia hạn',
      variant: AppButtonVariant.danger,
      height: 52,
      onPressed: () => _confirmCancel(context),
    );
  }
}
