import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// One of the fixed profile avatars. All of them are calm, gender-neutral
/// nature motifs drawn from the same rounded Material icon family the rest of
/// the app uses, so they scale cleanly at any size and sit inside the design
/// system. [id] is what gets stored (server + cache).
class AvatarDef {
  final String id;
  final IconData icon;
  final Color bg;
  final Color fg;
  const AvatarDef(this.id, this.icon, this.bg, this.fg);
}

// Tint pairs pulled straight from the palette, cycled so the set feels
// varied but never off-brand.
const _sage = (AppColors.sageTint, AppColors.sageTintText);
const _lav = (AppColors.lavenderTint, AppColors.lavenderTintText);
const _rose = (Color(0xFFFBE7EF), AppColors.danger);
const _mint = (AppColors.premiumMint, AppColors.premiumDarkA);
const _sky = (AppColors.loginTop, Color(0xFF3F5A73));

const List<(IconData, (Color, Color))> _entries = [
  (Icons.cloud_rounded, _sky),
  (Icons.bedtime_rounded, _lav),
  (Icons.wb_sunny_rounded, _rose),
  (Icons.wb_twilight_rounded, _sage),
  (Icons.star_rounded, _mint),
  (Icons.auto_awesome_rounded, _lav),
  (Icons.terrain_rounded, _sage),
  (Icons.waves_rounded, _sky),
  (Icons.water_drop_rounded, _mint),
  (Icons.air_rounded, _sky),
  (Icons.eco_rounded, _sage),
  (Icons.spa_rounded, _mint),
  (Icons.local_florist_rounded, _rose),
  (Icons.filter_vintage_rounded, _lav),
  (Icons.park_rounded, _sage),
  (Icons.forest_rounded, _mint),
  (Icons.grass_rounded, _sage),
  (Icons.favorite_rounded, _rose),
  (Icons.flare_rounded, _rose),
  (Icons.bubble_chart_rounded, _lav),
];

/// Stable ids — never reorder (they're persisted). Index-based names keep the
/// list easy to extend.
final List<AvatarDef> kAvatars = [
  for (var i = 0; i < _entries.length; i++)
    AvatarDef('a${i + 1}', _entries[i].$1, _entries[i].$2.$1, _entries[i].$2.$2),
];

AvatarDef avatarFor(String? id) =>
    kAvatars.firstWhere((a) => a.id == id, orElse: () => kAvatars.first);

class UserAvatar extends StatelessWidget {
  final String? avatarId;
  final double size;
  const UserAvatar({super.key, required this.avatarId, this.size = 56});

  @override
  Widget build(BuildContext context) {
    final def = avatarFor(avatarId);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: def.bg),
      alignment: Alignment.center,
      child: Icon(def.icon, size: size * 0.5, color: def.fg),
    );
  }
}
