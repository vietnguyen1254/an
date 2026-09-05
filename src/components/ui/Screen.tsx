import React from 'react';
import { StyleSheet, ScrollView, View, StyleProp, ViewStyle } from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaView } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { colors } from '../../theme/colors';

type Props = {
  children: React.ReactNode;
  gradient?: readonly [string, string, ...string[]];
  flat?: string;
  dark?: boolean;
  scroll?: boolean;
  edges?: ('top' | 'bottom' | 'left' | 'right')[];
  contentStyle?: StyleProp<ViewStyle>;
  noPadding?: boolean;
};

export default function Screen({
  children,
  gradient,
  flat = colors.appBg,
  dark = false,
  scroll = true,
  edges = ['top', 'bottom'],
  contentStyle,
  noPadding = false,
}: Props) {
  const Wrapper = scroll ? ScrollView : View;
  const wrapperProps = scroll
    ? { contentContainerStyle: [styles.content, !noPadding && styles.padding, contentStyle], showsVerticalScrollIndicator: false }
    : { style: [styles.content, !noPadding && styles.padding, contentStyle] };

  return (
    <View style={{ flex: 1, backgroundColor: gradient ? gradient[gradient.length - 1] : flat }}>
      <StatusBar style={dark ? 'light' : 'dark'} />
      {gradient && (
        <LinearGradient colors={gradient} style={StyleSheet.absoluteFill} />
      )}
      <SafeAreaView style={{ flex: 1 }} edges={edges}>
        <Wrapper {...(wrapperProps as any)}>{children}</Wrapper>
      </SafeAreaView>
    </View>
  );
}

const styles = StyleSheet.create({
  content: {
    flexGrow: 1,
  },
  padding: {
    paddingHorizontal: 22,
    paddingTop: 14,
    paddingBottom: 24,
  },
});
