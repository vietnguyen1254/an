import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/tab_icons.dart';
import 'home/home_screen.dart';
import 'journal/journal_screen.dart';
import 'meditation/library_screen.dart';
import 'profile/profile_screen.dart';

class MainTabs extends StatefulWidget {
  const MainTabs({super.key});

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _index = 0;

  static const _screens = [HomeScreen(), JournalScreen(), LibraryScreen(), ProfileScreen()];
  static const _labels = ['Trời', 'Cảm xúc', 'Thiền', 'Bạn'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xF5F7F9F7),
          border: Border(top: BorderSide(color: AppColors.ink.withValues(alpha: 0.07))),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 66,
            child: Row(
              children: List.generate(4, (i) {
                final focused = i == _index;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _index = i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _iconFor(i, focused),
                        const SizedBox(height: 5),
                        Text(
                          _labels[i],
                          style: TextStyle(
                            fontFamily: 'BeVietnamPro',
                            fontWeight: focused ? FontWeight.w500 : FontWeight.w400,
                            fontSize: 11,
                            color: focused ? AppColors.sage : AppColors.ink.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconFor(int i, bool focused) {
    switch (i) {
      case 0:
        return SkyIcon(focused: focused);
      case 1:
        return HeartIcon(focused: focused);
      case 2:
        return MeditationIcon(focused: focused);
      default:
        return ProfileIcon(focused: focused);
    }
  }
}
