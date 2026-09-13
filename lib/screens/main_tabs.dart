import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'home/home_screen.dart';
import 'journal/journal_screen.dart';
import 'meditation/library_screen.dart';
import 'profile/profile_screen.dart';

class MainTabs extends StatefulWidget {
  final int initialIndex;
  const MainTabs({super.key, this.initialIndex = 0});

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  late int _index = widget.initialIndex;

  // The journal tab gets its own nested Navigator so pushing a day's detail
  // stays within the tab's content area — the bottom bar (owned by this
  // outer Scaffold) stays visible instead of being covered by a full-screen
  // route. Other tabs still push full-screen via the root Navigator.
  final _journalNavKey = GlobalKey<NavigatorState>();

  List<Widget> get _screens => [
        const HomeScreen(),
        const LibraryScreen(),
        Navigator(
          key: _journalNavKey,
          onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => const JournalScreen()),
        ),
        const ProfileScreen(),
      ];
  static const _labels = ['Cảm xúc', 'Thiền/Thở', 'Lịch sử', 'Bạn'];

  @override
  Widget build(BuildContext context) {
    // Pull the whole bar 10px closer to the bottom edge instead of giving it
    // the device's full home-indicator inset.
    final bottomInset = (MediaQuery.paddingOf(context).bottom - 20).clamp(0.0, double.infinity);
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xF5F7F9F7),
          border: Border(top: BorderSide(color: AppColors.ink.withValues(alpha: 0.07))),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SizedBox(
            height: 68,
            child: Row(
              children: List.generate(4, (i) {
                final focused = i == _index;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _index = i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _iconFor(i, focused),
                        const SizedBox(height: 6),
                        Text(
                          _labels[i],
                          style: TextStyle(
                            fontFamily: 'BeVietnamPro',
                            fontWeight: focused ? FontWeight.w500 : FontWeight.w400,
                            fontSize: 12.65,
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
    const icons = [
      Icons.cloud_rounded, // Cảm xúc — Mây
      Icons.self_improvement_rounded, // Thiền/Thở
      Icons.history_rounded, // Lịch sử
      Icons.person_rounded, // Bạn
    ];
    return Icon(
      icons[i],
      size: 26.45,
      color: focused ? AppColors.sage : AppColors.ink.withValues(alpha: 0.4),
    );
  }
}
