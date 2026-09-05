import React from 'react';
import { View, Text, Pressable, StyleSheet, ViewStyle, StyleProp } from 'react-native';
import { colors } from '../../theme/colors';
import { fontFamily } from '../../theme/typography';

export function Eyebrow({ children, dark = false, style }: { children: React.ReactNode; dark?: boolean; style?: StyleProp<ViewStyle> }) {
  return (
    <Text style={[styles.eyebrow, { color: dark ? 'rgba(255,255,255,0.5)' : colors.inkFaint }, style]}>
      {children}
    </Text>
  );
}

export function Card({ children, style, muted = false }: { children: React.ReactNode; style?: StyleProp<ViewStyle>; muted?: boolean }) {
  return <View style={[styles.card, muted && styles.cardMuted, style]}>{children}</View>;
}

export function Chip({
  label,
  selected,
  onPress,
  tone = 'sage',
}: {
  label: string;
  selected?: boolean;
  onPress?: () => void;
  tone?: 'sage' | 'lavender';
}) {
  const on = !!selected;
  const bg = on ? (tone === 'sage' ? colors.sageTint : colors.lavenderTint) : '#FFFFFF';
  const text = on ? (tone === 'sage' ? colors.sageTintText : colors.lavenderTintText) : colors.inkMuted;
  const border = on ? 'rgba(111,158,138,0.4)' : colors.inkHairline;
  return (
    <Pressable
      onPress={onPress}
      style={{
        height: 38,
        paddingHorizontal: 16,
        borderRadius: 19,
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: bg,
        borderWidth: 1,
        borderColor: border,
      }}
    >
      <Text style={{ fontFamily: on ? fontFamily.sansMedium : fontFamily.sans, fontSize: 13.5, color: text }}>{label}</Text>
    </Pressable>
  );
}

export function SwitchRow({ title, sub, time, on = true, isLast = false }: { title: string; sub?: string; time?: string; on?: boolean; isLast?: boolean }) {
  return (
    <View style={[styles.row, !isLast && styles.rowBorder]}>
      <View style={{ flex: 1 }}>
        <Text style={styles.rowTitle}>{title}</Text>
        {!!sub && <Text style={styles.rowSub}>{sub}</Text>}
      </View>
      {!!time && <Text style={styles.rowTime}>{time}</Text>}
      <ToggleSwitch on={on} />
    </View>
  );
}

export function ToggleSwitch({ on }: { on: boolean }) {
  return (
    <View style={{ width: 52, height: 28, borderRadius: 14, backgroundColor: on ? colors.sage : 'rgba(27,36,32,0.14)', justifyContent: 'center' }}>
      <View style={{ position: 'absolute', right: on ? 3 : undefined, left: on ? undefined : 3, width: 22, height: 22, borderRadius: 11, backgroundColor: '#fff' }} />
    </View>
  );
}

export function ListRow({ title, detail, isLast = false, danger = false }: { title: string; detail?: string; isLast?: boolean; danger?: boolean }) {
  return (
    <View style={[styles.row, !isLast && styles.rowBorder]}>
      <Text style={[styles.rowTitle, danger && { color: colors.danger, fontFamily: fontFamily.sansMedium }]}>{title}</Text>
      {!!detail && <Text style={styles.rowTime}>{detail}</Text>}
    </View>
  );
}

export function ProgressBar({ pct, color = colors.sage, trackColor = 'rgba(27,36,32,0.09)', height = 6 }: { pct: number; color?: string; trackColor?: string; height?: number }) {
  return (
    <View style={{ height, borderRadius: height / 2, backgroundColor: trackColor, overflow: 'hidden' }}>
      <View style={{ height, width: `${pct}%`, borderRadius: height / 2, backgroundColor: color }} />
    </View>
  );
}

const styles = StyleSheet.create({
  eyebrow: {
    fontFamily: fontFamily.sans,
    fontSize: 11,
    letterSpacing: 1.1,
    textTransform: 'uppercase',
  },
  card: {
    backgroundColor: colors.card,
    borderRadius: 22,
    borderWidth: 1,
    borderColor: colors.inkHairline,
    padding: 20,
  },
  cardMuted: {
    backgroundColor: 'rgba(255,255,255,0.7)',
    borderWidth: 0,
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 18,
    paddingVertical: 16,
  },
  rowBorder: {
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(27,36,32,0.05)',
  },
  rowTitle: {
    flex: 1,
    fontFamily: fontFamily.sans,
    fontSize: 15,
    color: colors.ink,
  },
  rowSub: {
    fontFamily: fontFamily.sansLight,
    fontSize: 12,
    color: colors.inkMuted,
    marginTop: 2,
  },
  rowTime: {
    fontFamily: fontFamily.sans,
    fontSize: 14,
    color: colors.inkFaint,
    marginRight: 4,
  },
});
