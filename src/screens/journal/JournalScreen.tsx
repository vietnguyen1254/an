import React, { useState } from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '../../navigation/types';
import Screen from '../../components/ui/Screen';
import { colors } from '../../theme/colors';
import { fontFamily } from '../../theme/typography';
import { useAppStore } from '../../state/store';

type Nav = NativeStackNavigationProp<RootStackParamList>;

const DAY_COLORS = [colors.sage, colors.rose, colors.lavender, 'rgba(27,36,32,0.14)', colors.sage, colors.sage, colors.blueGray];
const RANGE_TABS = ['Tháng', 'Tuần', 'Năm'];

export default function JournalScreen() {
  const navigation = useNavigation<Nav>();
  const entries = useAppStore((s) => s.entries);
  const [tab, setTab] = useState(0);

  return (
    <Screen flat={colors.appBg}>
      <Text style={styles.title}>Cảm xúc</Text>

      <View style={styles.tabs}>
        {RANGE_TABS.map((t, i) => (
          <Pressable key={t} style={[styles.tab, i === tab && styles.tabActive]} onPress={() => setTab(i)}>
            <Text style={[styles.tabText, i === tab && styles.tabTextActive]}>{t}</Text>
          </Pressable>
        ))}
      </View>

      <View style={styles.calendarCard}>
        <View style={styles.rowBetween}>
          <Text style={styles.cardTitle}>Tháng 9, 2026</Text>
          <Text style={styles.cardMeta}>24 / 30 ngày</Text>
        </View>
        <View style={styles.grid}>
          {Array.from({ length: 30 }).map((_, i) => {
            const filled = i <= 23;
            return (
              <Pressable
                key={i}
                style={[styles.cell, { backgroundColor: filled ? DAY_COLORS[i % 7] : 'rgba(27,36,32,0.06)' }]}
                onPress={() => entries[0] && navigation.navigate('DayDetail', { entryId: entries[0].id })}
              />
            );
          })}
        </View>
        <View style={styles.legendRow}>
          <Legend color={colors.sage} label="Bình yên" />
          <Legend color={colors.rose} label="Vui" />
          <Legend color={colors.lavender} label="Lo lắng" />
          <Legend color="rgba(27,36,32,0.14)" label="Chưa ghi" />
        </View>
      </View>

      <View style={styles.calendarCard}>
        <Text style={styles.eyebrow}>Mây nhận thấy</Text>
        <Text style={styles.insight}>Bạn bình yên nhất vào Chủ nhật, và hay lo lắng vào chiều thứ Hai.</Text>
      </View>

      <View style={styles.statRow}>
        <View style={styles.statCard}>
          <Text style={styles.statLabel}>Chủ đề nổi bật</Text>
          <Text style={styles.statValue}>Công việc</Text>
          <Text style={styles.statMeta}>8 lần trong 30 ngày</Text>
        </View>
        <View style={styles.statCard}>
          <Text style={styles.statLabel}>Thiền</Text>
          <Text style={styles.statValue}>3 giờ 40</Text>
          <Text style={styles.statMeta}>tháng này</Text>
        </View>
      </View>
    </Screen>
  );
}

function Legend({ color, label }: { color: string; label: string }) {
  return (
    <View style={styles.legendItem}>
      <View style={[styles.legendDot, { backgroundColor: color }]} />
      <Text style={styles.legendText}>{label}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  title: { fontFamily: fontFamily.serif, fontSize: 27, color: colors.ink },
  tabs: { flexDirection: 'row', gap: 6, marginTop: 16, backgroundColor: 'rgba(27,36,32,0.05)', borderRadius: 14, padding: 4 },
  tab: { flex: 1, height: 32, borderRadius: 11, alignItems: 'center', justifyContent: 'center' },
  tabActive: { backgroundColor: '#fff' },
  tabText: { fontFamily: fontFamily.sans, fontSize: 13, color: 'rgba(27,36,32,0.5)' },
  tabTextActive: { fontFamily: fontFamily.sansMedium, color: colors.ink },
  calendarCard: { backgroundColor: '#fff', borderRadius: 24, borderWidth: 1, borderColor: 'rgba(27,36,32,0.06)', padding: 20, marginTop: 16 },
  rowBetween: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'baseline' },
  cardTitle: { fontFamily: fontFamily.sansMedium, fontSize: 15, color: colors.ink },
  cardMeta: { fontFamily: fontFamily.sansLight, fontSize: 12.5, color: 'rgba(27,36,32,0.45)' },
  grid: { flexDirection: 'row', flexWrap: 'wrap', gap: 7, marginTop: 16 },
  cell: { width: '12%', aspectRatio: 1, borderRadius: 6 },
  legendRow: { flexDirection: 'row', gap: 14, flexWrap: 'wrap', marginTop: 18 },
  legendItem: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  legendDot: { width: 10, height: 10, borderRadius: 3 },
  legendText: { fontFamily: fontFamily.sansLight, fontSize: 11.5, color: 'rgba(27,36,32,0.5)' },
  eyebrow: { fontFamily: fontFamily.sans, fontSize: 11, letterSpacing: 1, textTransform: 'uppercase', color: 'rgba(27,36,32,0.45)' },
  insight: { fontFamily: fontFamily.serif, fontSize: 18, lineHeight: 27, color: colors.ink, marginTop: 10 },
  statRow: { flexDirection: 'row', gap: 12, marginTop: 14 },
  statCard: { flex: 1, backgroundColor: '#fff', borderRadius: 22, borderWidth: 1, borderColor: 'rgba(27,36,32,0.06)', padding: 18 },
  statLabel: { fontFamily: fontFamily.sansLight, fontSize: 12, color: 'rgba(27,36,32,0.5)' },
  statValue: { fontFamily: fontFamily.serif, fontSize: 21, color: colors.ink, marginTop: 8 },
  statMeta: { fontFamily: fontFamily.sansLight, fontSize: 12, color: 'rgba(27,36,32,0.45)', marginTop: 4 },
});
