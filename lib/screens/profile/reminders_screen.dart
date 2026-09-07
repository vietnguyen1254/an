import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../widgets/basics.dart';

class _Notif {
  final String time;
  final String tag;
  final String body;
  final double opacity;
  const _Notif(this.time, this.tag, this.body, this.opacity);
}

const _notifs = [
  _Notif('An · 07:00', 'bây giờ', 'Chào buổi sáng. Ba phút thở trước khi ngày bắt đầu nhé?', 0.14),
  _Notif('An · 12:30', 'Góc nhìn hôm nay', '"Bình an không phải là hết việc. Là bạn thôi chống lại ngày hôm nay." — Justin', 0.11),
  _Notif('An · 21:00', 'trước khi ngủ', 'Hôm nay bạn thế nào? Mây đang chờ bạn kể.', 0.09),
];

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              const Text('Nhắc nhở', style: TextStyle(fontFamily: 'Lora', fontSize: 27, color: AppColors.ink)),
              const SizedBox(height: 8),
              Text('Mây nhắc nhẹ, không đòi. Bạn tắt bất cứ lúc nào.', style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13.5, height: 22 / 13.5, color: AppColors.ink.withValues(alpha: 0.58))),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(colors: [Color(0xFF2B4A55), Color(0xFF16242A)]),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TRÊN MÀN HÌNH KHOÁ', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 10.5, letterSpacing: 1, color: Colors.white.withValues(alpha: 0.45))),
                    const SizedBox(height: 12),
                    ..._notifs.map((n) => Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: Container(
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: n.opacity), borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text(n.time, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w500, fontSize: 12, color: Colors.white.withValues(alpha: 0.85))),
                                  Text(n.tag, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 11, color: Colors.white.withValues(alpha: 0.45))),
                                ]),
                                const SizedBox(height: 5),
                                Text(n.body, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13, height: 20 / 13, color: Colors.white.withValues(alpha: 0.75))),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.ink.withValues(alpha: 0.06))),
                clipBehavior: Clip.hardEdge,
                child: const Column(children: [
                  SwitchRow(title: 'Thiền buổi sáng', sub: 'mỗi ngày', time: '07:00', on: true),
                  SwitchRow(title: 'Thiền buổi tối', sub: 'mỗi ngày', time: '21:00', on: true),
                  SwitchRow(title: 'Ghi cảm xúc', sub: 'nếu chưa ghi trong ngày', time: '21:30', on: true),
                  SwitchRow(title: 'Câu nói mỗi ngày', sub: 'một câu, buổi trưa', on: true, isLast: true),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
