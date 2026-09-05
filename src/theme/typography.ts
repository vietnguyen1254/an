import { TextStyle } from 'react-native';
import { colors } from './colors';

// Lora (serif) for emotional / editorial headings, Be Vietnam Pro (sans, full
// Vietnamese diacritic support) for everything else.
export const fontFamily = {
  serif: 'Lora_400Regular',
  serifMedium: 'Lora_500Medium',
  sansLight: 'BeVietnamPro_300Light',
  sans: 'BeVietnamPro_400Regular',
  sansMedium: 'BeVietnamPro_500Medium',
  sansSemibold: 'BeVietnamPro_600SemiBold',
} as const;

export const type = {
  display: {
    fontFamily: fontFamily.serif,
    fontSize: 30,
    lineHeight: 40,
    color: colors.ink,
  } as TextStyle,
  h1: {
    fontFamily: fontFamily.serif,
    fontSize: 27,
    lineHeight: 35,
    color: colors.ink,
  } as TextStyle,
  h2: {
    fontFamily: fontFamily.serif,
    fontSize: 22,
    lineHeight: 29,
    color: colors.ink,
  } as TextStyle,
  h3: {
    fontFamily: fontFamily.serif,
    fontSize: 19,
    lineHeight: 27,
    color: colors.ink,
  } as TextStyle,
  eyebrow: {
    fontFamily: fontFamily.sans,
    fontSize: 11,
    letterSpacing: 1.1,
    textTransform: 'uppercase',
    color: colors.inkFaint,
  } as TextStyle,
  body: {
    fontFamily: fontFamily.sansLight,
    fontSize: 15,
    lineHeight: 26,
    color: colors.inkSoft,
  } as TextStyle,
  bodySm: {
    fontFamily: fontFamily.sansLight,
    fontSize: 13,
    lineHeight: 21,
    color: colors.inkMuted,
  } as TextStyle,
  label: {
    fontFamily: fontFamily.sans,
    fontSize: 15,
    color: colors.ink,
  } as TextStyle,
  labelSm: {
    fontFamily: fontFamily.sans,
    fontSize: 13,
    color: colors.inkMuted,
  } as TextStyle,
  button: {
    fontFamily: fontFamily.sansMedium,
    fontSize: 16,
    color: colors.white,
  } as TextStyle,
  caption: {
    fontFamily: fontFamily.sansLight,
    fontSize: 12.5,
    color: colors.inkMuted,
  } as TextStyle,
};

export const fontsToLoad = {
  // filled in by App.tsx via @expo-google-fonts packages
};
