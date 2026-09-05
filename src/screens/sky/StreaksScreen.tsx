import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import Screen from '../../components/ui/Screen';
import { colors } from '../../theme/colors';
import { fontFamily } from '../../theme/typography';
import { useAppStore } from '../../state/store';

const DECORATIONS = [
  { title: 'Nắng sớm', status: 'Đã mở', unlocked: true, bg: ['#FBE7EF', '#F6F8F6'] as const },
  { title: 'Gió nhẹ', status: 'Đã mở', unlocked: true, bg: [colors.sageTint, '#F6F8F6'] as const },
  { title: 'Đèn lồng', status: 'còn 3 ngày', unlocked: false },
  { title: 'Sao đêm', status: '30 ngày', unlocked: false },
];

export default function StreaksScreen() {
  const streakDays = useAppStore((s) => s.streakDays);
  const pips = Array.from({ length: 7 }).map((_, i) => i < Math.min(streakDays, 6));

  return (
    <Screen flat={colors.appBg}>
      <Text style={styles.title}>Trời của bạn</Text>

      <LinearGradient colors={['#EAF2EE', '#D3E4DC']} style={styles.streakCard}>
        <Text style={styles.streakNum}>{streakDays}</Text>
        <Text style={styles.streakLabel}>ngày liên tục ghé qua</Text>
        <View style={styles.pipRow}>
          {pips.map((on, i) => (
            <View key={i} style={[styles.pip, on ? styles.pipOn : styles.pipOff]} />
          ))}
        </View>
      </LinearGradient>

      <Text style={styles.eyebrow}>Vật trang trí</Text>
      <View style={styles.decoGrid}>
        {DECORATIONS.map((d) => (
          <View key={d.title} style={[styles.decoCard, !d.unlocked && { opacity: 0.6 }]}>
            <View
              style={[
                styles.decoThumb,
                d.unlocked ? { backgroundColor: (d.bg as any)[0] } : styles.decoThumbLocked,
              ]}
            />
            <Text style={styles.decoTitle}>{d.title}</Text>
            <Text style={[styles.decoStatus, d.unlocked && { color: colors.sage }]}>{d.status}</Text>
          </View>
        ))}
      </View>

      <View style={styles.footNote}>
        <Text style={styles.footText}>Chuỗi ngày không mất nếu bạn nghỉ một hôm. Mây vẫn ở đó.</Text>
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  title: { fontFamily: fontFamily.serif, fontSize: 27, color: colors.ink },
  streakCard: { borderRadius: 26, padding: 22, marginTop: 16, alignItems: 'center', borderWidth: 1, borderColor: 'rgba(255,255,255,0.8)' },
  streakNum: { fontFamily: fontFamily.serif, fontSize: 46, color: colors.ink },
  streakLabel: { fontFamily: fontFamily.sans, fontSize: 14, color: 'rgba(27,36,32,0.55)', marginTop: 8 },
  pipRow: { flexDirection: 'row', gap: 7, marginTop: 18 },
  pip: { width: 26, height: 26, borderRadius: 9 },
  pipOn: { backgroundColor: colors.sage },
  pipOff: { backgroundColor: 'rgba(255,255,255,0.7)', borderWidth: 1, borderColor: 'rgba(27,36,32,0.2)', borderStyle: 'dashed' },
  eyebrow: { fontFamily: fontFamily.sans, fontSize: 11, letterSpacing: 1, textTransform: 'uppercase', color: 'rgba(27,36,32,0.45)', marginTop: 26 },
  decoGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 12, marginTop: 12 },
  decoCard: { width: '47.5%', backgroundColor: '#fff', borderRadius: 20, borderWidth: 1, borderColor: 'rgba(27,36,32,0.06)', padding: 16 },
  decoThumb: { height: 64, borderRadius: 14 },
  decoThumbLocked: { backgroundColor: '#EEF0ED' },
  decoTitle: { fontFamily: fontFamily.sansMedium, fontSize: 14, color: colors.ink, marginTop: 12 },
  decoStatus: { fontFamily: fontFamily.sansLight, fontSize: 12, color: 'rgba(27,36,32,0.45)', marginTop: 2 },
  footNote: { backgroundColor: 'rgba(111,158,138,0.1)', borderRadius: 20, padding: 18, marginTop: 16 },
  footText: { fontFamily: fontFamily.sansLight, fontSize: 13.5, lineHeight: 22, color: 'rgba(27,36,32,0.7)' },
});
