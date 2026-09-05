import React, { useEffect, useRef } from 'react';
import { Animated, Easing, View, StyleSheet } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { MoodKey } from '../theme/colors';

// Mây — the cloud companion. Ported 1:1 from the CSS construction in
// `May copy.dc.html`: a cloud silhouette built from three overlapping
// circular "lobes" plus a rounded base, plain views/gradients only (no
// illustration asset exists yet — see the design chat transcript).

type MoodSpec = {
  fill: string;
  shade: string;
  glow: string;
  ink: string;
  eyes: 'arc' | 'dot' | 'sad' | 'heavy';
  mouth: 'grin' | 'smile' | 'line' | 'o' | 'frown' | 'flat';
  cheeks?: boolean;
  brows?: boolean;
  sparkly?: boolean;
  sway?: boolean;
  drops?: number;
};

const MOODS: Record<MoodKey, MoodSpec> = {
  'binh-yen': {
    fill: '#FCFDFF', shade: 'rgba(176,196,214,0.32)', glow: 'rgba(255,255,255,0.62)',
    ink: '#5C6E80', eyes: 'arc', mouth: 'smile',
  },
  vui: {
    fill: '#FFFDF6', shade: 'rgba(238,203,150,0.3)', glow: 'rgba(250,226,180,0.6)',
    ink: '#6B5B3E', eyes: 'arc', mouth: 'grin', cheeks: true, sparkly: true, sway: true,
  },
  'binh-thuong': {
    fill: '#FBFCFD', shade: 'rgba(176,196,214,0.26)', glow: 'rgba(255,255,255,0.6)',
    ink: '#6A7885', eyes: 'dot', mouth: 'line',
  },
  'lo-lang': {
    fill: '#F4F2F9', shade: 'rgba(146,132,180,0.34)', glow: 'rgba(170,160,196,0.44)',
    ink: '#5D5375', eyes: 'dot', mouth: 'o', brows: true, sway: true,
  },
  buon: {
    fill: '#E9EFF5', shade: 'rgba(116,142,174,0.42)', glow: 'rgba(136,155,186,0.4)',
    ink: '#4E617A', eyes: 'sad', mouth: 'frown', drops: 4,
  },
  'kiet-suc': {
    fill: '#F0EFEB', shade: 'rgba(160,152,136,0.36)', glow: 'rgba(192,168,148,0.32)',
    ink: '#6E6656', eyes: 'heavy', mouth: 'flat', drops: 1,
  },
};

const BOX = 200;
// bodyWrap: 178x120 centered in the 200x200 box -> top-left offset:
const BW_X = (BOX - 178) / 2; // 11
const BW_Y = (BOX - 120) / 2; // 40

function Eye({ type, x, droop, ink }: { type: MoodSpec['eyes']; x: number; droop: number; ink: string }) {
  if (type === 'arc') {
    return (
      <View style={{
        position: 'absolute', left: BW_X + x, top: BW_Y + 62 + droop, width: 15, height: 8,
        borderTopWidth: 2, borderTopColor: ink, borderTopLeftRadius: 15, borderTopRightRadius: 15,
        opacity: 0.8,
      }} />
    );
  }
  if (type === 'sad') {
    return (
      <View style={{
        position: 'absolute', left: BW_X + x + 3, top: BW_Y + 64, width: 9, height: 9,
        borderRadius: 5, backgroundColor: ink, opacity: 0.75,
      }} />
    );
  }
  if (type === 'heavy') {
    return (
      <View style={{
        position: 'absolute', left: BW_X + x, top: BW_Y + 68, width: 15, height: 3,
        borderRadius: 2, backgroundColor: ink, opacity: 0.7,
      }} />
    );
  }
  return (
    <View style={{
      position: 'absolute', left: BW_X + x + 4, top: BW_Y + 63, width: 7, height: 7,
      borderRadius: 4, backgroundColor: ink, opacity: 0.72,
    }} />
  );
}

function Mouth({ type, ink }: { type: MoodSpec['mouth']; ink: string }) {
  const cx = BW_X + 89; // 50% of the 178-wide bodyWrap
  if (type === 'grin') {
    return <View style={{ position: 'absolute', left: cx - 9.5, top: BW_Y + 78, width: 19, height: 10, borderWidth: 2, borderColor: 'transparent', borderBottomColor: ink, borderBottomLeftRadius: 14, borderBottomRightRadius: 14, opacity: 0.75 }} />;
  }
  if (type === 'smile') {
    return <View style={{ position: 'absolute', left: cx - 6.5, top: BW_Y + 79, width: 13, height: 7, borderBottomWidth: 2, borderBottomColor: ink, borderBottomLeftRadius: 10, borderBottomRightRadius: 10, opacity: 0.62 }} />;
  }
  if (type === 'line') {
    return <View style={{ position: 'absolute', left: cx - 6.5, top: BW_Y + 82, width: 13, height: 2, borderRadius: 2, backgroundColor: ink, opacity: 0.6 }} />;
  }
  if (type === 'o') {
    return <View style={{ position: 'absolute', left: cx - 4, top: BW_Y + 78, width: 8, height: 8, borderRadius: 4, borderWidth: 2, borderColor: ink, opacity: 0.7 }} />;
  }
  if (type === 'frown') {
    return <View style={{ position: 'absolute', left: cx - 6.5, top: BW_Y + 84, width: 13, height: 7, borderTopWidth: 2, borderTopColor: ink, borderTopLeftRadius: 10, borderTopRightRadius: 10, opacity: 0.6 }} />;
  }
  return <View style={{ position: 'absolute', left: cx - 5, top: BW_Y + 84, width: 10, height: 2, borderRadius: 2, backgroundColor: ink, opacity: 0.5 }} />;
}

export default function May({ mood = 'binh-yen', size = 96 }: { mood?: MoodKey; size?: number }) {
  const m = MOODS[mood] ?? MOODS['binh-yen'];
  const droop = m.eyes === 'heavy' ? 6 : 0;
  const scale = size / BOX;

  const sway = useRef(new Animated.Value(0)).current;
  const float = useRef(new Animated.Value(0)).current;
  const spark = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    const loops: Animated.CompositeAnimation[] = [];
    if (m.sway) {
      const loop = Animated.loop(
        Animated.sequence([
          Animated.timing(sway, { toValue: 1, duration: 2250, easing: Easing.inOut(Easing.sin), useNativeDriver: true }),
          Animated.timing(sway, { toValue: -1, duration: 2250, easing: Easing.inOut(Easing.sin), useNativeDriver: true }),
          Animated.timing(sway, { toValue: 0, duration: 2250, easing: Easing.inOut(Easing.sin), useNativeDriver: true }),
        ]),
      );
      loop.start();
      loops.push(loop);
    } else {
      sway.setValue(0);
    }
    const floatLoop = Animated.loop(
      Animated.sequence([
        Animated.timing(float, { toValue: 1, duration: 3500, easing: Easing.inOut(Easing.sin), useNativeDriver: true }),
        Animated.timing(float, { toValue: 0, duration: 3500, easing: Easing.inOut(Easing.sin), useNativeDriver: true }),
      ]),
    );
    floatLoop.start();
    loops.push(floatLoop);
    if (m.sparkly) {
      const sparkLoop = Animated.loop(
        Animated.sequence([
          Animated.timing(spark, { toValue: 1, duration: 1700, easing: Easing.inOut(Easing.sin), useNativeDriver: true }),
          Animated.timing(spark, { toValue: 0, duration: 1700, easing: Easing.inOut(Easing.sin), useNativeDriver: true }),
        ]),
      );
      sparkLoop.start();
      loops.push(sparkLoop);
    }
    return () => loops.forEach((l) => l.stop());
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [mood]);

  const translateX = sway.interpolate({ inputRange: [-1, 1], outputRange: [-3, 3] });
  const translateY = float.interpolate({ inputRange: [0, 1], outputRange: [0, -6] });
  const sparkOpacity = spark.interpolate({ inputRange: [0, 1], outputRange: [0.15, 0.7] });

  return (
    <View style={{ width: size, height: size, alignItems: 'center', justifyContent: 'center' }}>
      <Animated.View style={{ width: BOX, height: BOX, transform: [{ scale }, { translateY }] }}>
        {/* glow (approximated radial falloff with stacked rings) */}
        <View pointerEvents="none" style={[styles.glowRing, { width: 220, height: 190, left: (BOX - 220) / 2, top: (BOX - 190) / 2, backgroundColor: m.glow, opacity: 0.35 }]} />
        <View pointerEvents="none" style={[styles.glowRing, { width: 160, height: 140, left: (BOX - 160) / 2, top: (BOX - 140) / 2, backgroundColor: m.glow, opacity: 0.45 }]} />

        {m.sparkly && (
          <>
            <Animated.View style={{ position: 'absolute', left: 20, top: 38, width: 6, height: 6, borderRadius: 2, backgroundColor: 'rgba(246,216,166,0.7)', transform: [{ rotate: '45deg' }], opacity: sparkOpacity }} />
            <Animated.View style={{ position: 'absolute', right: 20, top: 54, width: 5, height: 5, borderRadius: 2, backgroundColor: 'rgba(246,216,166,0.6)', transform: [{ rotate: '45deg' }], opacity: sparkOpacity }} />
          </>
        )}

        <Animated.View style={{ position: 'absolute', left: 0, top: 0, width: BOX, height: BOX, transform: [{ translateX }] }}>
          {/* cloud lobes */}
          <View style={{ position: 'absolute', left: BW_X + 14, top: BW_Y + 34, width: 66, height: 66, borderRadius: 33, backgroundColor: m.fill }} />
          <View style={{ position: 'absolute', left: BW_X + 52, top: BW_Y + 8, width: 88, height: 88, borderRadius: 44, backgroundColor: m.fill }} />
          <View style={{ position: 'absolute', left: BW_X + 108, top: BW_Y + 38, width: 62, height: 62, borderRadius: 31, backgroundColor: m.fill }} />
          <View style={{ position: 'absolute', left: BW_X + 2, top: BW_Y + 56, width: 174, height: 60, borderRadius: 30, backgroundColor: m.fill }} />
          {/* underside shade */}
          <LinearGradient
            colors={['rgba(0,0,0,0)', m.shade]}
            style={{ position: 'absolute', left: BW_X + 2, top: BW_Y + 82, width: 174, height: 34, borderBottomLeftRadius: 30, borderBottomRightRadius: 30 }}
          />
          {/* top shine */}
          <LinearGradient
            colors={['rgba(255,255,255,0.95)', 'rgba(255,255,255,0)']}
            style={{ position: 'absolute', left: BW_X + 64, top: BW_Y + 22, width: 52, height: 22, borderRadius: 26, opacity: 0.85 }}
          />

          {m.brows && (
            <>
              <View style={{ position: 'absolute', left: BW_X + 58, top: BW_Y + 50, width: 16, height: 7, borderTopWidth: 2, borderTopColor: 'rgba(85,103,122,0.6)', borderTopLeftRadius: 8, borderTopRightRadius: 8, transform: [{ rotate: '-12deg' }] }} />
              <View style={{ position: 'absolute', left: BW_X + 104, top: BW_Y + 50, width: 16, height: 7, borderTopWidth: 2, borderTopColor: 'rgba(85,103,122,0.6)', borderTopLeftRadius: 8, borderTopRightRadius: 8, transform: [{ rotate: '12deg' }] }} />
            </>
          )}

          <Eye type={m.eyes} x={60} droop={droop} ink={m.ink} />
          <Eye type={m.eyes} x={104} droop={droop} ink={m.ink} />

          {m.cheeks && (
            <>
              <View style={{ position: 'absolute', left: BW_X + 46, top: BW_Y + 76, width: 15, height: 9, borderRadius: 6, backgroundColor: 'rgba(232,176,190,0.3)' }} />
              <View style={{ position: 'absolute', left: BW_X + 118, top: BW_Y + 76, width: 15, height: 9, borderRadius: 6, backgroundColor: 'rgba(232,176,190,0.3)' }} />
            </>
          )}

          <Mouth type={m.mouth} ink={m.ink} />
        </Animated.View>

        {!!m.drops && (
          <View pointerEvents="none" style={{ position: 'absolute', left: 0, right: 0, top: 132, height: 60 }}>
            {Array.from({ length: m.drops }).map((_, i) => (
              <RainDrop key={i} index={i} />
            ))}
          </View>
        )}
      </Animated.View>
    </View>
  );
}

function RainDrop({ index }: { index: number }) {
  const fall = useRef(new Animated.Value(0)).current;
  useEffect(() => {
    const loop = Animated.loop(
      Animated.sequence([
        Animated.delay(index * 420),
        Animated.timing(fall, { toValue: 1, duration: 1900, easing: Easing.linear, useNativeDriver: true }),
        Animated.timing(fall, { toValue: 0, duration: 0, useNativeDriver: true }),
      ]),
    );
    loop.start();
    return () => loop.stop();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);
  const translateY = fall.interpolate({ inputRange: [0, 1], outputRange: [0, 46] });
  const opacity = fall.interpolate({ inputRange: [0, 0.18, 1], outputRange: [0, 0.85, 0] });
  const w = index % 2 ? 5 : 6;
  const h = index % 2 ? 11 : 13;
  return (
    <Animated.View
      style={{
        position: 'absolute', left: 34 + index * 34, top: 0, width: w, height: h,
        borderRadius: w / 2, backgroundColor: 'rgba(126,152,184,0.62)',
        transform: [{ translateY }], opacity,
      }}
    />
  );
}

const styles = StyleSheet.create({
  glowRing: {
    position: 'absolute',
    borderRadius: 999,
  },
});
