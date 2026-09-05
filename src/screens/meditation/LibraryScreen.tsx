import React from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '../../navigation/types';
import Screen from '../../components/ui/Screen';
import { colors } from '../../theme/colors';
import { fontFamily } from '../../theme/typography';
import May from '../../components/May';
import { useAppStore } from '../../state/store';

type Nav = NativeStackNavigationProp<RootStackParamList>;

const CATEGORIES = ['Tất cả', 'Lo lắng', 'Ngủ', 'Tập trung'];

export default function LibraryScreen() {
  const navigation = useNavigation<Nav>();
  const plan = useAppStore((s) => s.plan);
  const isPremium = plan !== 'free';

  const openGuided = (title: string, guide: string, minutes: number, free: boolean) => {
    if (!free && !isPremium) navigation.navigate('Paywall');
    else navigation.navigate('Player', { kind: 'guided', title, guide, minutes });
  };

  return (
    <Screen flat={colors.appBg} noPadding contentStyle={{ paddingBottom: 40 }}>
      <View style={{ paddingHorizontal: 22, paddingTop: 14 }}>
        <Text style={styles.title}>Thiền</Text>
        <View style={styles.searchBar}>
          <Text style={styles.searchPh}>Tìm bài thiền, chủ đề…</Text>
        </View>
      </View>

      <View style={styles.chipRow}>
        {CATEGORIES.map((c, i) => (
          <View key={c} style={[styles.chip, i === 0 && styles.chipActive]}>
            <Text style={[styles.chipText, i === 0 && styles.chipTextActive]}>{c}</Text>
          </View>
        ))}
      </View>

      <View style={{ paddingHorizontal: 22, marginTop: 14 }}>
        <Pressable onPress={() => navigation.navigate('Player', { kind: 'breathing', title: 'Thở cùng Mây', minutes: 5 })}>
          <LinearGradient colors={['#2E4A42', '#16201E']} style={styles.hero}>
            <View style={styles.heroMay}><May mood="binh-yen" size={110} /></View>
            <Text style={styles.heroEyebrow}>Miễn phí · bài tập thở</Text>
            <Text style={styles.heroTitle}>Thở cùng Mây</Text>
            <Text style={styles.heroSub}>5 phút · hít 4, giữ 4, thở 6</Text>
          </LinearGradient>
        </Pressable>
      </View>

      <View style={styles.sectionHeadRow}>
        <Text style={styles.eyebrow}>Một phút cùng Justin Nguyễn</Text>
        <Text style={styles.seeAll}>Xem tất cả</Text>
      </View>
      <View style={styles.minuteRow}>
        <Pressable style={styles.minuteCard} onPress={() => navigation.navigate('MinuteWithJustin')}>
          <View style={[styles.minuteThumb, { backgroundColor: '#E4EDF3' }]} />
          <Text style={styles.minuteTitle}>Khi lòng mình ồn ào</Text>
          <Text style={styles.minuteMeta}>Video · 90 giây</Text>
        </Pressable>
        <Pressable style={styles.minuteCard} onPress={() => navigation.navigate('MinuteWithJustin')}>
          <View style={[styles.minuteThumb, { backgroundColor: '#EDE9F4' }]} />
          <Text style={styles.minuteTitle}>Một điều để nhớ</Text>
          <Text style={styles.minuteMeta}>Đọc · 1 phút</Text>
        </Pressable>
      </View>

      <Text style={[styles.eyebrow, { marginTop: 20, marginHorizontal: 22 }]}>Khi bạn lo lắng</Text>
      <View style={{ paddingHorizontal: 22, marginTop: 12, gap: 10 }}>
        <Pressable style={styles.listCard} onPress={() => openGuided('Buông một ngày dài', 'Justin Nguyễn', 12, true)}>
          <View style={[styles.listThumb, { backgroundColor: colors.sageTint }]} />
          <View style={{ flex: 1 }}>
            <Text style={styles.listTitle}>Buông một ngày dài</Text>
            <Text style={styles.listMeta}>Thiền dẫn · Justin Nguyễn · 12 phút</Text>
          </View>
          <View style={styles.freePill}><Text style={styles.freePillText}>Miễn phí</Text></View>
        </Pressable>
        <Pressable style={styles.listCard} onPress={() => openGuided('Quét cơ thể', 'Trâm Nguyễn', 15, false)}>
          <View style={[styles.listThumb, { backgroundColor: colors.lavenderTint }]} />
          <View style={{ flex: 1 }}>
            <Text style={styles.listTitle}>Quét cơ thể</Text>
            <Text style={styles.listMeta}>Thiền dẫn · Trâm Nguyễn · 15 phút</Text>
          </View>
          <LockIcon />
        </Pressable>
      </View>
    </Screen>
  );
}

function LockIcon() {
  return (
    <View style={{ width: 26, height: 26, borderRadius: 13, backgroundColor: 'rgba(27,36,32,0.06)', alignItems: 'center', justifyContent: 'center' }}>
      <View style={{ width: 9, height: 7, borderWidth: 1.6, borderColor: 'rgba(27,36,32,0.42)', borderTopWidth: 0, borderRadius: 2 }} />
    </View>
  );
}

const styles = StyleSheet.create({
  title: { fontFamily: fontFamily.serif, fontSize: 27, color: colors.ink },
  searchBar: { height: 44, borderRadius: 22, backgroundColor: 'rgba(27,36,32,0.05)', justifyContent: 'center', paddingHorizontal: 18, marginTop: 16 },
  searchPh: { fontFamily: fontFamily.sansLight, fontSize: 14, color: 'rgba(27,36,32,0.4)' },
  chipRow: { flexDirection: 'row', gap: 8, marginTop: 16, paddingHorizontal: 22 },
  chip: { height: 34, paddingHorizontal: 16, borderRadius: 17, backgroundColor: '#fff', borderWidth: 1, borderColor: 'rgba(27,36,32,0.08)', alignItems: 'center', justifyContent: 'center' },
  chipActive: { backgroundColor: colors.ink, borderColor: colors.ink },
  chipText: { fontFamily: fontFamily.sans, fontSize: 13, color: 'rgba(27,36,32,0.6)' },
  chipTextActive: { color: '#fff', fontFamily: fontFamily.sansMedium },
  hero: { height: 158, borderRadius: 26, padding: 20, justifyContent: 'flex-end', overflow: 'hidden' },
  heroMay: { position: 'absolute', right: -20, top: 0 },
  heroEyebrow: { fontFamily: fontFamily.sans, fontSize: 11, letterSpacing: 1, textTransform: 'uppercase', color: 'rgba(255,255,255,0.55)', maxWidth: 200 },
  heroTitle: { fontFamily: fontFamily.serif, fontSize: 24, color: '#fff', marginTop: 8, maxWidth: 210 },
  heroSub: { fontFamily: fontFamily.sansLight, fontSize: 13, color: 'rgba(255,255,255,0.6)', marginTop: 6 },
  sectionHeadRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'baseline', paddingHorizontal: 22, marginTop: 20 },
  eyebrow: { fontFamily: fontFamily.sans, fontSize: 11, letterSpacing: 1, textTransform: 'uppercase', color: 'rgba(27,36,32,0.45)' },
  seeAll: { fontFamily: fontFamily.sansLight, fontSize: 12.5, color: 'rgba(27,36,32,0.45)' },
  minuteRow: { flexDirection: 'row', gap: 12, paddingHorizontal: 22, marginTop: 12 },
  minuteCard: { flex: 1, backgroundColor: '#fff', borderRadius: 20, borderWidth: 1, borderColor: 'rgba(27,36,32,0.06)', padding: 14 },
  minuteThumb: { height: 70, borderRadius: 14 },
  minuteTitle: { fontFamily: fontFamily.sansMedium, fontSize: 14, color: colors.ink, marginTop: 12 },
  minuteMeta: { fontFamily: fontFamily.sansLight, fontSize: 12, color: 'rgba(27,36,32,0.5)', marginTop: 3 },
  listCard: { flexDirection: 'row', alignItems: 'center', gap: 14, backgroundColor: '#fff', borderRadius: 20, borderWidth: 1, borderColor: 'rgba(27,36,32,0.06)', padding: 14 },
  listThumb: { width: 56, height: 56, borderRadius: 16 },
  listTitle: { fontFamily: fontFamily.sansMedium, fontSize: 15, color: colors.ink },
  listMeta: { fontFamily: fontFamily.sansLight, fontSize: 12.5, color: 'rgba(27,36,32,0.5)', marginTop: 3 },
  freePill: { height: 26, paddingHorizontal: 10, borderRadius: 13, backgroundColor: colors.sageTint, alignItems: 'center', justifyContent: 'center' },
  freePillText: { fontFamily: fontFamily.sansMedium, fontSize: 11, color: colors.sageTintText },
});
