import React, { useEffect, useRef, useState } from 'react';
import { View, Text, Pressable, Animated, Easing, StyleSheet } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '../../navigation/types';
import Screen from '../../components/ui/Screen';
import { colors } from '../../theme/colors';
import { fontFamily } from '../../theme/typography';
import May from '../../components/May';

type Props = NativeStackScreenProps<RootStackParamList, 'Player'>;

const BREATHS = ['Hít vào…', 'Giữ…', 'Thở ra…'];

function fmt(sec: number) {
  const m = Math.floor(sec / 60);
  const s = Math.floor(sec % 60);
  return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
}

export default function PlayerScreen({ route, navigation }: Props) {
  const params = route.params ?? { kind: 'breathing' as const, title: 'Thở cùng Mây', minutes: 5 };
  const total = (params.minutes ?? 5) * 60;
  const [playing, setPlaying] = useState(true);
  const [phase, setPhase] = useState(0);
  const [elapsed, setElapsed] = useState(0);
  const breathe = useRef(new Animated.Value(0.86)).current;

  useEffect(() => {
    const t = setInterval(() => {
      if (playing) setPhase((p) => (p + 1) % 3);
    }, 4500);
    return () => clearInterval(t);
  }, [playing]);

  useEffect(() => {
    const t = setInterval(() => {
      if (playing) setElapsed((e) => Math.min(total, e + 1));
    }, 1000);
    return () => clearInterval(t);
  }, [playing, total]);

  useEffect(() => {
    const loop = Animated.loop(
      Animated.sequence([
        Animated.timing(breathe, { toValue: 1.06, duration: 4500, easing: Easing.inOut(Easing.sin), useNativeDriver: true }),
        Animated.timing(breathe, { toValue: 0.86, duration: 4500, easing: Easing.inOut(Easing.sin), useNativeDriver: true }),
      ]),
    );
    loop.start();
    return () => loop.stop();
  }, [breathe]);

  const pct = Math.min(100, (elapsed / total) * 100);
  const breathLabel = playing ? BREATHS[phase] : 'Tạm dừng';

  return (
    <Screen flat={colors.sessionDarkC} dark scroll={false}>
      <View style={styles.wrap}>
        <View style={styles.topRow}>
          <Pressable onPress={() => navigation.goBack()}>
            <Text style={styles.topDone}>Xong</Text>
          </Pressable>
          <Text style={styles.topTitle}>{params.kind === 'guided' ? 'Đang phát' : params.title}</Text>
          <View style={styles.dotsBtn} />
        </View>

        {params.kind === 'breathing' ? (
          <>
            <View style={styles.breathStage}>
              <Animated.View style={[styles.breathRingOuter, { transform: [{ scale: breathe }] }]} />
              <View style={styles.breathRingMid} />
              <View style={styles.breathRingInner} />
              <May mood="binh-yen" size={110} />
            </View>
            <View style={{ alignItems: 'center', marginTop: 6 }}>
              <Text style={styles.breathLabel}>{breathLabel}</Text>
              <Text style={styles.breathSub}>Theo nhịp của Mây, không cần gắng</Text>
            </View>
          </>
        ) : (
          <>
            <View style={styles.cover} />
            <Text style={styles.guidedTitle}>{params.title}</Text>
            <View style={styles.guideRow}>
              <View style={styles.guideThumb} />
              <View style={{ flex: 1 }}>
                <Text style={styles.guideName}>Thiền dẫn · {params.guide}</Text>
                <Text style={styles.guideMeta}>Chuỗi "Trở về" · bài 3 / 7</Text>
              </View>
              <View style={styles.followBtn}><Text style={styles.followText}>Theo dõi</Text></View>
            </View>
          </>
        )}

        <View style={{ flex: 1 }} />
        <View style={styles.timeRow}>
          <Text style={styles.timeText}>{fmt(elapsed)}</Text>
          <Text style={styles.timeText}>-{fmt(Math.max(0, total - elapsed))}</Text>
        </View>
        <View style={styles.progressTrack}>
          <View style={[styles.progressFill, { width: `${pct}%` }]} />
        </View>
        <View style={styles.controlsRow}>
          <View style={styles.skipBtn}><Text style={styles.skipText}>15</Text></View>
          <Pressable style={styles.playBtn} onPress={() => setPlaying((p) => !p)}>
            <Text style={styles.playText}>{playing ? 'Dừng' : 'Tiếp'}</Text>
          </Pressable>
          <View style={styles.skipBtn}><Text style={styles.skipText}>15</Text></View>
        </View>
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  wrap: { flex: 1, paddingHorizontal: 26, paddingTop: 8, paddingBottom: 40 },
  topRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  topDone: { fontFamily: fontFamily.sans, fontSize: 14, color: 'rgba(255,255,255,0.5)' },
  topTitle: { fontFamily: fontFamily.sans, fontSize: 13, color: 'rgba(255,255,255,0.4)' },
  dotsBtn: { width: 22, height: 22, borderRadius: 11, borderWidth: 1, borderColor: 'rgba(255,255,255,0.2)' },
  breathStage: { height: 320, marginTop: 30, alignItems: 'center', justifyContent: 'center' },
  breathRingOuter: { position: 'absolute', width: 300, height: 300, borderRadius: 150, backgroundColor: 'rgba(246,189,212,0.16)' },
  breathRingMid: { position: 'absolute', width: 236, height: 236, borderRadius: 118, borderWidth: 1, borderColor: 'rgba(255,255,255,0.14)' },
  breathRingInner: { position: 'absolute', width: 170, height: 170, borderRadius: 85, borderWidth: 1, borderColor: 'rgba(255,255,255,0.08)' },
  breathLabel: { fontFamily: fontFamily.serif, fontSize: 30, color: '#fff' },
  breathSub: { fontFamily: fontFamily.sansLight, fontSize: 14, color: 'rgba(255,255,255,0.45)', marginTop: 10 },
  cover: { marginTop: 20, height: 260, borderRadius: 28, backgroundColor: 'rgba(255,255,255,0.06)' },
  guidedTitle: { fontFamily: fontFamily.serif, fontSize: 27, lineHeight: 36, color: '#fff', marginTop: 24 },
  guideRow: { flexDirection: 'row', alignItems: 'center', gap: 12, marginTop: 16 },
  guideThumb: { width: 36, height: 36, borderRadius: 18, backgroundColor: 'rgba(255,255,255,0.14)' },
  guideName: { fontFamily: fontFamily.sansMedium, fontSize: 14, color: '#fff' },
  guideMeta: { fontFamily: fontFamily.sansLight, fontSize: 12.5, color: 'rgba(255,255,255,0.45)', marginTop: 2 },
  followBtn: { height: 32, paddingHorizontal: 14, borderRadius: 16, borderWidth: 1, borderColor: 'rgba(255,255,255,0.22)', alignItems: 'center', justifyContent: 'center' },
  followText: { fontFamily: fontFamily.sans, fontSize: 12.5, color: 'rgba(255,255,255,0.75)' },
  timeRow: { flexDirection: 'row', justifyContent: 'space-between' },
  timeText: { fontFamily: fontFamily.sansLight, fontSize: 12, color: 'rgba(255,255,255,0.45)' },
  progressTrack: { height: 3, borderRadius: 2, backgroundColor: 'rgba(255,255,255,0.14)', marginTop: 8, overflow: 'hidden' },
  progressFill: { height: 3, borderRadius: 2, backgroundColor: 'rgba(255,255,255,0.75)' },
  controlsRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 34, marginTop: 28 },
  skipBtn: { width: 44, height: 44, borderRadius: 22, borderWidth: 1, borderColor: 'rgba(255,255,255,0.18)', alignItems: 'center', justifyContent: 'center' },
  skipText: { fontFamily: fontFamily.sans, fontSize: 12, color: 'rgba(255,255,255,0.6)' },
  playBtn: { width: 72, height: 72, borderRadius: 36, backgroundColor: '#fff', alignItems: 'center', justifyContent: 'center' },
  playText: { fontFamily: fontFamily.sansMedium, fontSize: 13, color: '#16201E' },
});
