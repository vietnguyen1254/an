import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';

class AppScreen extends StatelessWidget {
  final Widget child;
  final List<Color>? gradient;
  final Color flat;
  final bool dark;
  final bool scroll;
  final EdgeInsets padding;
  final bool top;
  final bool bottom;

  const AppScreen({
    super.key,
    required this.child,
    this.gradient,
    this.flat = AppColors.appBg,
    this.dark = false,
    this.scroll = true,
    this.padding = const EdgeInsets.fromLTRB(22, 14, 22, 24),
    this.top = true,
    this.bottom = true,
  });

  @override
  Widget build(BuildContext context) {
    final body = scroll
        ? SingleChildScrollView(padding: padding, child: child)
        : Padding(padding: padding, child: child);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Container(
        decoration: BoxDecoration(
          color: gradient == null ? flat : null,
          gradient: gradient == null
              ? null
              : LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: gradient!),
        ),
        child: SafeArea(top: top, bottom: bottom, child: body),
      ),
    );
  }
}
