import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../widgets/user_avatar.dart';

class AvatarPickerScreen extends StatelessWidget {
  const AvatarPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final current = avatarFor(state.authAvatar).id;

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Text('Xong', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 14, color: AppColors.ink.withValues(alpha: 0.5))),
              ),
              const SizedBox(height: 22),
              const Text('Chọn hình đại diện', style: TextStyle(fontFamily: 'Lora', fontSize: 27, color: AppColors.ink)),
              const SizedBox(height: 8),
              Text(
                'Một hình nhỏ để nhận ra bạn. Không có gì phải đúng — chọn cái bạn thấy hợp.',
                style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13.5, height: 22 / 13.5, color: AppColors.ink.withValues(alpha: 0.58)),
              ),
              const SizedBox(height: 22),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  for (final a in kAvatars)
                    GestureDetector(
                      onTap: () {
                        context.read<AppState>().setAvatar(a.id);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: a.id == current ? AppColors.sage : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(3),
                        child: UserAvatar(avatarId: a.id, size: 60),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
