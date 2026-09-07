import 'package:flutter/material.dart';

const _active = Color(0xFF6F9E8A);
const _inactive = Color(0x481B2420);

class SkyIcon extends StatelessWidget {
  final bool focused;
  const SkyIcon({super.key, required this.focused});

  @override
  Widget build(BuildContext context) {
    final c = focused ? _active : _inactive;
    return SizedBox(
      width: 24,
      height: 22,
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned(left: 2, bottom: 3, child: Container(width: 20, height: 9, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(5)))),
        Positioned(left: 4, top: 3, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle))),
        Positioned(left: 12, top: 5, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle))),
      ]),
    );
  }
}

class HeartIcon extends StatelessWidget {
  final bool focused;
  const HeartIcon({super.key, required this.focused});

  @override
  Widget build(BuildContext context) {
    final c = focused ? _active : _inactive;
    return SizedBox(
      width: 24,
      height: 22,
      child: Stack(clipBehavior: Clip.none, alignment: Alignment.topCenter, children: [
        Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: c, width: 2))),
        Positioned(left: 11, top: 4, child: Container(width: 2, height: 7, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(1)))),
        Positioned(left: 11, top: 9, child: Container(width: 6, height: 2, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(1)))),
      ]),
    );
  }
}

class MeditationIcon extends StatelessWidget {
  final bool focused;
  const MeditationIcon({super.key, required this.focused});

  @override
  Widget build(BuildContext context) {
    final c = focused ? _active : _inactive;
    Widget bar(double w, double leftPad) => Padding(
          padding: EdgeInsets.only(left: leftPad),
          child: Container(width: w, height: 3, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
        );
    return SizedBox(
      width: 24,
      height: 22,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [bar(18, 0), const SizedBox(height: 4), bar(12, 3), const SizedBox(height: 4), bar(6, 6)],
      ),
    );
  }
}

class ProfileIcon extends StatelessWidget {
  final bool focused;
  const ProfileIcon({super.key, required this.focused});

  @override
  Widget build(BuildContext context) {
    final c = focused ? _active : _inactive;
    return SizedBox(
      width: 24,
      height: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: 9, height: 9, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(height: 2),
          Container(
            width: 17,
            height: 9,
            decoration: BoxDecoration(
              color: c,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(9),
                topRight: Radius.circular(9),
                bottomLeft: Radius.circular(3),
                bottomRight: Radius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
