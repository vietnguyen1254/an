import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/basics.dart';
import '../onboarding/onboarding_screen.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _confirming = false;
  final _controller = TextEditingController();

  void _confirmDelete() {
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const OnboardingScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final canDelete = _controller.text.trim().toUpperCase() == 'XOA';

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
              const Text('Riêng tư & dữ liệu', style: TextStyle(fontFamily: 'Lora', fontSize: 27, color: AppColors.ink)),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: AppColors.sage.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(22)),
                child: Text(
                  'Nhật ký cảm xúc của bạn được lưu trên máy và trong tài khoản của bạn. An không bán dữ liệu và không dùng nội dung bạn viết để quảng cáo.',
                  style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13.5, height: 22 / 13.5, color: AppColors.ink.withValues(alpha: 0.7)),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
                clipBehavior: Clip.hardEdge,
                child: const Column(children: [
                  AppListRow(title: 'Xuất dữ liệu', detail: null),
                  SwitchRow(title: 'Sao lưu iCloud', on: true),
                  AppListRow(title: 'Chính sách riêng tư', isLast: true),
                ]),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Xoá tài khoản', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.danger)),
                    const SizedBox(height: 8),
                    Text(
                      'Toàn bộ nhật ký cảm xúc, chuỗi ngày và trời của bạn sẽ bị xoá. Việc này không thể hoàn lại. Gói Premium cần huỷ riêng trong App Store.',
                      style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13, height: 22 / 13, color: AppColors.ink.withValues(alpha: 0.6)),
                    ),
                    if (!_confirming) ...[
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () => setState(() => _confirming = true),
                        child: const Text('Xoá tài khoản của bạn…', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 14, color: AppColors.danger)),
                      ),
                    ],
                  ],
                ),
              ),
              if (_confirming) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Xoá tài khoản của bạn?', style: TextStyle(fontFamily: 'Lora', fontSize: 19, color: AppColors.ink)),
                      const SizedBox(height: 8),
                      Text('Nhập XOA để xác nhận.', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13, height: 22 / 13, color: AppColors.ink.withValues(alpha: 0.6))),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _controller,
                        onChanged: (_) => setState(() {}),
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(fontFamily: 'BeVietnamPro', fontSize: 16, color: AppColors.ink),
                        decoration: InputDecoration(
                          hintText: 'XOA',
                          hintStyle: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 16, color: AppColors.ink.withValues(alpha: 0.35)),
                          filled: true,
                          fillColor: const Color(0xFFFAFBFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.ink.withValues(alpha: 0.1))),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => setState(() => _confirming = false),
                              style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), side: BorderSide(color: AppColors.ink.withValues(alpha: 0.12))),
                              child: Text('Giữ lại', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 15, color: AppColors.ink.withValues(alpha: 0.6))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppButton(label: 'Xoá', height: 48, variant: AppButtonVariant.danger, onPressed: canDelete ? _confirmDelete : null),
                        ),
                      ]),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
