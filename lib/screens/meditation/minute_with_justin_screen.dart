import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import 'player_screen.dart';

class MinuteWithJustinScreen extends StatelessWidget {
  const MinuteWithJustinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text('Đóng', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 14, color: AppColors.ink.withValues(alpha: 0.5))),
                    ),
                    Text('Chia sẻ', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 14, color: AppColors.ink.withValues(alpha: 0.5))),
                  ],
                ),
              ),
              Container(
                height: 212,
                color: const Color(0xFFDCE6EC),
                alignment: Alignment.center,
                child: Container(width: 62, height: 62, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.9))),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MỘT PHÚT CÙNG JUSTIN NGUYỄN', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 10.5, letterSpacing: 1, color: AppColors.ink.withValues(alpha: 0.45))),
                    const SizedBox(height: 10),
                    const Text('Khi lòng mình ồn ào', style: TextStyle(fontFamily: 'Lora', fontSize: 27, height: 36 / 27, color: AppColors.ink)),
                    const SizedBox(height: 14),
                    Row(children: [
                      Container(width: 30, height: 30, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFDFE7EC))),
                      const SizedBox(width: 10),
                      Text('Justin Nguyễn · 90 giây', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, color: AppColors.ink.withValues(alpha: 0.55))),
                    ]),
                    const SizedBox(height: 20),
                    Text(
                      'Có những ngày trong đầu bạn ồn như một cái chợ. Bạn không cần dẹp hết tiếng ồn đó. Chỉ cần ngồi xuống, thở ba hơi, và để nó đi qua như một cơn mưa rào.',
                      style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 15, height: 28 / 15, color: AppColors.ink.withValues(alpha: 0.72)),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const PlayerScreen(kind: PlayerKind.guided, title: 'Trở về hơi thở', guide: 'Justin Nguyễn', minutes: 12),
                      )),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), border: Border.all(color: AppColors.ink.withValues(alpha: 0.05)), borderRadius: BorderRadius.circular(22)),
                        child: Row(children: [
                          Container(width: 52, height: 52, decoration: BoxDecoration(color: AppColors.sageTint, borderRadius: BorderRadius.circular(16))),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('NGHE TIẾP', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 10.5, letterSpacing: 1, color: AppColors.ink.withValues(alpha: 0.45))),
                                const SizedBox(height: 5),
                                const Text('Trở về hơi thở', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.ink)),
                                const SizedBox(height: 3),
                                Text('Thiền dẫn · Justin Nguyễn · 12 phút', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, color: AppColors.ink.withValues(alpha: 0.5))),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
