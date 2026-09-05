import React from 'react';
import { Pressable, Text, StyleSheet, ViewStyle, StyleProp } from 'react-native';
import { colors } from '../../theme/colors';
import { fontFamily } from '../../theme/typography';

type Variant = 'dark' | 'sage' | 'light' | 'mint' | 'outlineDark' | 'outlineLight' | 'ghost';

export default function Button({
  label,
  onPress,
  variant = 'dark',
  style,
  height = 56,
}: {
  label: string;
  onPress?: () => void;
  variant?: Variant;
  style?: StyleProp<ViewStyle>;
  height?: number;
}) {
  const v = variantStyles[variant];
  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => [
        styles.base,
        { height, borderRadius: height / 2, backgroundColor: v.bg, borderColor: v.border, borderWidth: v.border ? 1 : 0 },
        pressed && { opacity: 0.85 },
        style,
      ]}
    >
      <Text style={[styles.label, { color: v.text }]}>{label}</Text>
    </Pressable>
  );
}

const variantStyles: Record<Variant, { bg: string; text: string; border?: string }> = {
  dark: { bg: colors.ink, text: '#F6F8F6' },
  sage: { bg: colors.sage, text: '#FFFFFF' },
  light: { bg: '#FFFFFF', text: colors.ink },
  mint: { bg: colors.premiumMint, text: '#16201E' },
  outlineDark: { bg: 'transparent', text: colors.inkMuted, border: 'rgba(27,36,32,0.14)' },
  outlineLight: { bg: 'transparent', text: 'rgba(255,255,255,0.9)', border: 'rgba(255,255,255,0.24)' },
  ghost: { bg: 'transparent', text: colors.inkMuted },
};

const styles = StyleSheet.create({
  base: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 20,
  },
  label: {
    fontFamily: fontFamily.sansMedium,
    fontSize: 16,
  },
});
