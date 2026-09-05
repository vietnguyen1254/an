import React from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '../../navigation/types';
import Screen from '../../components/ui/Screen';
import { colors } from '../../theme/colors';
import { fontFamily } from '../../theme/typography';
import { useAppStore } from '../../state/store';

type Props = NativeStackScreenProps<RootStackParamList, 'GuideProfile'>;

const GUIDES = {
  justin: {
    name: 'Justin Nguyễn',
    bio: 'Justin dẫn thiền và nói về chữa lành từ năm 2019. Giọng chậm, ít chỉ dẫn, nhiều khoảng lặng — dành cho người vừa hết một ngày dài.',
    stats: [['42', 'bài thiền'], ['6', 'chuỗi bài'], ['18', 'góc nhìn']],
    tracks: [
      { title: 'Buông một ngày dài', meta: '12 phút', free: true },
      { title: 'Trở về hơi thở', meta: '12 phút · chuỗi "Trở về"', free: false },
    ],
    coDrive: 'tram' as const,
    coDriveLabel: 'Trâm Nguyễn',
  },
  tram: {
    name: 'Trâm Nguyễn',
    bio: 'Trâm cùng chồng — Justin — dẫn thiền cho An. Giọng nữ nhẹ, ấm, thường dẫn các bài về giấc ngủ và quét cơ thể.',
    stats: [['15', 'bài thiền'], ['2', 'chuỗi bài'], ['4', 'góc nhìn']],
    tracks: [{ title: 'Quét cơ thể', meta: '15 phút', free: false }],
    coDrive: 'justin' as const,
    coDriveLabel: 'Justin Nguyễn',
  },
};

export default function GuideProfileScreen({ route, navigation }: Props) {
  const guideKey = route.params?.guide ?? 'justin';
  const guide = GUIDES[guideKey];
  const plan = useAppStore((s) => s.plan);
  const isPremium = plan !== 'free';

  const openTrack = (free: boolean, title: string) => {
    if (!free && !isPremium) navigation.navigate('Paywall');
    else navigation.navigate('Player', { kind: 'guided', title, guide: guide.name, minutes: 12 });
  };

  return (
    <Screen flat={colors.appBg} noPadding contentStyle={{ paddingBottom: 32 }}>
      <View style={styles.cover}>
        <Pressable onPress={() => navigation.goBack()} style={styles.backBtn}>
          <Text style={styles.backText}>Quay lại</Text>
        </Pressable>
        <Text style={styles.coverPh}>ảnh chân dung người dẫn</Text>
      </View>
      <View style={{ paddingHorizontal: 22 }}>
        <Text style={styles.eyebrow}>Người dẫn thiền</Text>
        <Text style={styles.name}>{guide.name}</Text>
        <Text style={styles.bio}>{guide.bio}</Text>
        <View style={styles.statsRow}>
          {guide.stats.map(([num, label]) => (
            <View key={label}>
              <Text style={styles.statNum}>{num}</Text>
              <Text style={styles.statLabel}>{label}</Text>
            </View>
          ))}
        </View>
        <Text style={[styles.eyebrow, { marginTop: 28 }]}>Bài thiền của {guide.name.split(' ')[0]}</Text>
        <View style={{ gap: 10, marginTop: 12 }}>
          {guide.tracks.map((t) => (
            <Pressable key={t.title} style={styles.trackCard} onPress={() => openTrack(t.free, t.title)}>
              <View style={[styles.trackThumb, { backgroundColor: t.free ? colors.sageTint : colors.lavenderTint }]} />
              <View style={{ flex: 1 }}>
                <Text style={styles.trackTitle}>{t.title}</Text>
                <Text style={styles.trackMeta}>{t.meta}</Text>
              </View>
              {t.free ? (
                <View style={styles.freePill}><Text style={styles.freePillText}>Miễn phí</Text></View>
              ) : (
                <View style={styles.lockDot} />
              )}
            </Pressable>
          ))}
        </View>
        <Pressable style={styles.coDriveCard} onPress={() => navigation.push('GuideProfile', { guide: guide.coDrive })}>
          <View style={styles.coDriveThumb} />
          <View style={{ flex: 1 }}>
            <Text style={styles.eyebrow}>Cùng dẫn</Text>
            <Text style={styles.coDriveName}>{guide.coDriveLabel}</Text>
          </View>
        </Pressable>
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  cover: { height: 300, backgroundColor: '#DCE6EC', justifyContent: 'flex-end', padding: 24 },
  backBtn: { position: 'absolute', left: 24, top: 74 },
  backText: { fontFamily: fontFamily.sans, fontSize: 14, color: 'rgba(27,36,32,0.5)' },
  coverPh: { fontFamily: fontFamily.sansLight, fontSize: 10.5, color: 'rgba(27,36,32,0.4)' },
  eyebrow: { fontFamily: fontFamily.sans, fontSize: 10.5, letterSpacing: 1, textTransform: 'uppercase', color: 'rgba(27,36,32,0.45)', marginTop: 24 },
  name: { fontFamily: fontFamily.serif, fontSize: 29, color: colors.ink, marginTop: 8 },
  bio: { fontFamily: fontFamily.sansLight, fontSize: 14.5, lineHeight: 26, color: 'rgba(27,36,32,0.7)', marginTop: 14 },
  statsRow: { flexDirection: 'row', gap: 24, marginTop: 22 },
  statNum: { fontFamily: fontFamily.serif, fontSize: 22, color: colors.ink },
  statLabel: { fontFamily: fontFamily.sansLight, fontSize: 12, color: 'rgba(27,36,32,0.5)', marginTop: 2 },
  trackCard: { flexDirection: 'row', alignItems: 'center', gap: 14, backgroundColor: '#fff', borderRadius: 20, borderWidth: 1, borderColor: 'rgba(27,36,32,0.06)', padding: 14 },
  trackThumb: { width: 52, height: 52, borderRadius: 15 },
  trackTitle: { fontFamily: fontFamily.sansMedium, fontSize: 15, color: colors.ink },
  trackMeta: { fontFamily: fontFamily.sansLight, fontSize: 12.5, color: 'rgba(27,36,32,0.5)', marginTop: 3 },
  freePill: { height: 26, paddingHorizontal: 10, borderRadius: 13, backgroundColor: colors.sageTint, alignItems: 'center', justifyContent: 'center' },
  freePillText: { fontFamily: fontFamily.sansMedium, fontSize: 11, color: colors.sageTintText },
  lockDot: { width: 26, height: 26, borderRadius: 13, backgroundColor: 'rgba(27,36,32,0.06)' },
  coDriveCard: { flexDirection: 'row', alignItems: 'center', gap: 14, backgroundColor: '#fff', borderRadius: 22, borderWidth: 1, borderColor: 'rgba(27,36,32,0.06)', padding: 16, marginTop: 22 },
  coDriveThumb: { width: 44, height: 44, borderRadius: 22, backgroundColor: '#DFE7EC' },
  coDriveName: { fontFamily: fontFamily.sansMedium, fontSize: 15, color: colors.ink, marginTop: 4 },
});
