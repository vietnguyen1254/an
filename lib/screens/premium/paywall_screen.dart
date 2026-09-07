import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../widgets/app_button.dart';
import 'payment_success_screen.dart';

const _features = [
  'Toàn bộ bài thiền dẫn bởi Justin Nguyễn và Trâm Nguyễn',
  'Chuỗi bài theo chủ đề: lo lắng, ngủ, tập trung, biết ơn',
  'Bài mới mỗi tuần',
];

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  PlanTier _selected = PlanTier.yearly;

  void _startTrial() {
    context.read<AppState>().setPlan(_selected);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PaymentSuccessScreen()));
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
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)),
                    child: const Text('×', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('AN PREMIUM', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 10.5, letterSpacing: 1.2, color: Colors.white.withValues(alpha: 0.5))),
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Mở khoá toàn bộ\nkhông gian chữa lành', style: TextStyle(fontFamily: 'Lora', fontSize: 30, height: 39 / 30, color: Colors.white)),
              ),
              const SizedBox(height: 26),
              ..._features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.premiumMint)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(f, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 14.5, height: 23 / 14.5, color: Colors.white.withValues(alpha: 0.82)))),
                      ],
                    ),
                  )),
              const SizedBox(height: 14),
              _PlanCard(
                title: 'Theo năm',
                price: '1.699.000đ',
                sub: '≈ 141.500đ mỗi tháng',
                badge: 'TIẾT KIỆM 29%',
                selected: _selected == PlanTier.yearly,
                onTap: () => setState(() => _selected = PlanTier.yearly),
              ),
              const SizedBox(height: 10),
              _PlanCard(
                title: 'Theo tháng',
                price: '199.000đ',
                sub: 'huỷ bất cứ lúc nào',
                selected: _selected == PlanTier.monthly,
                onTap: () => setState(() => _selected = PlanTier.monthly),
              ),
              const Spacer(),
              AppButton(label: 'Dùng thử 7 ngày miễn phí', variant: AppButtonVariant.light, onPressed: _startTrial),
              const SizedBox(height: 16),
              Text('Khôi phục mua hàng', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 13, color: Colors.white.withValues(alpha: 0.6))),
              const SizedBox(height: 12),
              Text(
                'Sau đó 1.699.000đ mỗi năm. Huỷ trước khi hết hạn thử thì không mất phí.\nMiễn phí vẫn có: theo dõi cảm xúc, bài tập thở, Góc nhìn hôm nay và một bài thiền.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 11.5, height: 18 / 11.5, color: Colors.white.withValues(alpha: 0.42)),
              ),
            ],
          ),
        ),
      ),
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

  const _PlanCard({required this.title, required this.price, required this.sub, this.badge, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: selected ? Colors.white.withValues(alpha: 0.07) : null,
            border: Border.all(color: selected ? AppColors.premiumMint : Colors.white.withValues(alpha: 0.16), width: selected ? 2 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white.withValues(alpha: 0.95))),
                  Text(price, style: TextStyle(fontFamily: 'Lora', fontSize: 20, color: Colors.white.withValues(alpha: 0.95))),
                ],
              ),
              const SizedBox(height: 6),
              Text(sub, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, color: Colors.white.withValues(alpha: 0.5))),
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
              decoration: BoxDecoration(color: AppColors.premiumMint, borderRadius: BorderRadius.circular(11)),
              child: Text(badge!, style: const TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w600, fontSize: 10.5, letterSpacing: 0.4, color: Color(0xFF1B3B33))),
            ),
          ),
      ]),
    );
  }
}
