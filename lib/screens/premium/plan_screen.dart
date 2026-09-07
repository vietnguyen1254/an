import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/basics.dart';
import 'paywall_screen.dart';

const _freeFeatures = ['Theo dõi cảm xúc mỗi ngày', 'Bài tập thở cùng Mây', 'Góc nhìn hôm nay', 'Một bài thiền: Buông một ngày dài'];

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
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [AppColors.premiumDarkA, AppColors.premiumDarkB])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CÒN KHOÁ', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 10.5, letterSpacing: 1, color: Colors.white.withValues(alpha: 0.5))),
            const SizedBox(height: 8),
            const Text('Toàn bộ bài thiền dẫn bởi Justin và Trâm, chuỗi bài theo chủ đề, bài mới mỗi tuần.', style: TextStyle(fontFamily: 'Lora', fontSize: 21, height: 29 / 21, color: Colors.white)),
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
      AppButton(label: 'Dùng thử 7 ngày miễn phí', onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaywallScreen()))),
      const SizedBox(height: 12),
      Text('Huỷ trước khi hết hạn thử thì không mất phí.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 11.5, color: AppColors.ink.withValues(alpha: 0.45))),
    ];
  }

  List<Widget> _monthlyBody(BuildContext context, AppState state) {
    return [
      const SizedBox(height: 18),
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [AppColors.premiumDarkA, AppColors.premiumDarkB])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ĐANG HOẠT ĐỘNG', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 10.5, letterSpacing: 1, color: Colors.white.withValues(alpha: 0.5))),
            const SizedBox(height: 8),
            const Text('An Premium · theo tháng', style: TextStyle(fontFamily: 'Lora', fontSize: 22, color: Colors.white)),
            const SizedBox(height: 8),
            Text('199.000đ · gia hạn 03/10/2026', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13, color: Colors.white.withValues(alpha: 0.55))),
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
            Text('1.699.000đ mỗi năm, tính ra 141.500đ một tháng. Phần còn lại của tháng này được trừ vào gói mới.', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13, height: 22 / 13, color: AppColors.ink.withValues(alpha: 0.65))),
            const SizedBox(height: 16),
            AppButton(label: 'Đổi sang gói năm', variant: AppButtonVariant.sage, height: 48, onPressed: () => state.setPlan(PlanTier.yearly)),
          ],
        ),
      ),
      const SizedBox(height: 14),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
        clipBehavior: Clip.hardEdge,
        child: const Column(children: [
          AppListRow(title: 'Phương thức thanh toán', detail: 'Apple ID'),
          AppListRow(title: 'Lịch sử thanh toán', isLast: true),
        ]),
      ),
      const SizedBox(height: 20),
      _cancelButton(context, state),
    ];
  }

  List<Widget> _yearlyBody(BuildContext context, AppState state) {
    return [
      const SizedBox(height: 18),
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [AppColors.premiumDarkA, AppColors.premiumDarkB])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ĐANG HOẠT ĐỘNG', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 10.5, letterSpacing: 1, color: Colors.white.withValues(alpha: 0.5))),
            const SizedBox(height: 8),
            const Text('An Premium · theo năm', style: TextStyle(fontFamily: 'Lora', fontSize: 22, color: Colors.white)),
            const SizedBox(height: 8),
            Text('1.699.000đ · gia hạn 12/03/2027', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13, color: Colors.white.withValues(alpha: 0.55))),
          ],
        ),
      ),
      const SizedBox(height: 14),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
        clipBehavior: Clip.hardEdge,
        child: const Column(children: [
          AppListRow(title: 'Phương thức thanh toán', detail: 'Apple ID'),
          AppListRow(title: 'Lịch sử thanh toán', isLast: true),
        ]),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: AppColors.sage.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
        child: Text(
          'Nếu bạn huỷ, phần miễn phí vẫn giữ nguyên: theo dõi cảm xúc, bài tập thở, Góc nhìn hôm nay và một bài thiền. Nhật ký cảm xúc của bạn không mất.',
          style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13, height: 22 / 13, color: AppColors.ink.withValues(alpha: 0.7)),
        ),
      ),
      const SizedBox(height: 20),
      _cancelButton(context, state),
    ];
  }

  Widget _cancelButton(BuildContext context, AppState state) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: () => state.setPlan(PlanTier.free),
        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)), side: BorderSide(color: AppColors.ink.withValues(alpha: 0.14))),
        child: Text('Huỷ gia hạn', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 15, color: AppColors.ink.withValues(alpha: 0.6))),
      ),
    );
  }
}
