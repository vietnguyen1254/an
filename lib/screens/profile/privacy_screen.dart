import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/basics.dart';
import '../onboarding/onboarding_screen.dart';
import 'privacy_policy_screen.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _confirming = false;
  bool _busy = false;
  String? _error;
  final _controller = TextEditingController();

  bool get _canDelete {
    const ok = {'XOÁ', 'XOA'};
    return ok.contains(_controller.text.trim().toUpperCase());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AppState>().deleteAccount();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Không xoá được lúc này. Kiểm tra kết nối mạng rồi thử lại.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Text('Quay lại', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 14, color: AppColors.ink.withValues(alpha: 0.5))),
              ),
              const SizedBox(height: 22),
              const Text('Riêng tư & dữ liệu', style: TextStyle(fontFamily: 'Lora', fontSize: 27, color: AppColors.ink)),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: AppColors.sage.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(22)),
                child: Text(
                  'Nhật ký cảm xúc của bạn được lưu trên máy và trong tài khoản của bạn. '
                  'An không bán dữ liệu và không dùng nội dung bạn viết để quảng cáo.',
                  style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13.5, height: 22 / 13.5, color: AppColors.ink.withValues(alpha: 0.7)),
                ),
              ),
              const SizedBox(height: 26),
              Text('CHÍNH SÁCH', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 11, letterSpacing: 1, color: AppColors.ink.withValues(alpha: 0.45))),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
                clipBehavior: Clip.hardEdge,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                  ),
                  child: Row(
                    children: [
                      const Expanded(child: AppListRow(title: 'Chính sách quyền riêng tư & điều khoản', isLast: true)),
                      Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.ink.withValues(alpha: 0.3)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Text('TÀI KHOẢN', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 11, letterSpacing: 1, color: AppColors.ink.withValues(alpha: 0.45))),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Xoá tài khoản', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.danger)),
                    const SizedBox(height: 8),
                    Text(
                      'Xoá vĩnh viễn tài khoản và toàn bộ dữ liệu của bạn khỏi máy và máy chủ. Việc này không thể hoàn lại.',
                      style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13, height: 22 / 13, color: AppColors.ink.withValues(alpha: 0.65)),
                    ),
                    if (!_confirming)
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: GestureDetector(
                          onTap: () => setState(() => _confirming = true),
                          child: const Text('Tôi muốn xoá tài khoản…', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.danger)),
                        ),
                      )
                    else ...[
                      const SizedBox(height: 16),
                      _bullet('Toàn bộ nhật ký cảm xúc, chuỗi ngày và thời gian thiền'),
                      _bullet('Tài khoản, tên, hình đại diện và thông tin đăng nhập'),
                      const SizedBox(height: 10),
                      Text(
                        'Gói Premium (nếu có) không tự huỷ khi xoá tài khoản và không được hoàn tiền. '
                        'Bạn cần huỷ riêng trong App Store hoặc Google Play.',
                        style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, height: 20 / 12.5, color: AppColors.ink.withValues(alpha: 0.6)),
                      ),
                      const SizedBox(height: 16),
                      Text('Nhập XOÁ để xác nhận', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 13, color: AppColors.ink.withValues(alpha: 0.6))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _controller,
                        onChanged: (_) => setState(() {}),
                        enabled: !_busy,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(fontFamily: 'BeVietnamPro', fontSize: 16, color: AppColors.ink),
                        decoration: InputDecoration(
                          hintText: 'XOÁ',
                          hintStyle: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 16, color: AppColors.ink.withValues(alpha: 0.35)),
                          filled: true,
                          fillColor: const Color(0xFFFAFBFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.ink.withValues(alpha: 0.1))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.ink.withValues(alpha: 0.1))),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(_error!, style: const TextStyle(fontFamily: 'BeVietnamPro', fontSize: 12.5, color: AppColors.danger)),
                      ],
                      const SizedBox(height: 14),
                      Row(children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: _busy ? null : () => setState(() { _confirming = false; _controller.clear(); _error = null; }),
                              style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), side: BorderSide(color: AppColors.ink.withValues(alpha: 0.12))),
                              child: Text('Giữ lại', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 15, color: AppColors.ink.withValues(alpha: 0.6))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppButton(
                            label: _busy ? 'Đang xoá…' : 'Xoá vĩnh viễn',
                            height: 48,
                            variant: AppButtonVariant.danger,
                            onPressed: (_canDelete && !_busy) ? _delete : null,
                          ),
                        ),
                      ]),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 7, right: 9),
              child: Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.ink.withValues(alpha: 0.4))),
            ),
            Expanded(
              child: Text(text, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13, height: 20 / 13, color: AppColors.ink.withValues(alpha: 0.7))),
            ),
          ],
        ),
      );
}
