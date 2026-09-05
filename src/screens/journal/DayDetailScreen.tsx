import React from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '../../navigation/types';
import Screen from '../../components/ui/Screen';
import { colors, moodColors, moodLabels } from '../../theme/colors';
import { fontFamily } from '../../theme/typography';
import May from '../../components/May';
import { useAppStore, TAGS, INTENSITY_LABELS } from '../../state/store';

type Props = NativeStackScreenProps<RootStackParamList, 'DayDetail'>;

export default function DayDetailScreen({ route, navigation }: Props) {
  const entry = useAppStore((s) => s.entries.find((e) => e.id === route.params.entryId));
  if (!entry) return null;

  const tagLabels = entry.tags.map((k) => TAGS.find((t) => t.key === k)?.label ?? k);

  return (
    <Screen flat={colors.appBg}>
      <View style={styles.topRow}>
        <Text style={styles.topMuted}>Tháng 9</Text>
        <View style={{ flexDirection: 'row', gap: 16 }}>
          <Pressable><Text style={styles.topMuted}>Sửa</Text></Pressable>
          <Pressable onPress={() => navigation.goBack()}><Text style={styles.topMuted}>Xoá</Text></Pressable>
        </View>
      </View>

      <Text style={styles.dateLabel}>{entry.dateLabel}</Text>
      <Text style={styles.moodTitle}>{moodLabels[entry.mood]}</Text>

      <View style={{ alignItems: 'center', marginTop: 8 }}>
        <May mood={entry.mood} size={130} />
      </View>

      <View style={styles.card}>
        <View style={styles.rowBetween}>
          <Text style={styles.eyebrow}>Mức độ</Text>
          <Text style={styles.mutedSm}>{INTENSITY_LABELS[entry.intensity - 1]}</Text>
        </View>
        <View style={styles.track}>
          <View style={[styles.trackFill, { width: `${entry.intensity * 20}%`, backgroundColor: moodColors[entry.mood] }]} />
        </View>

        <Text style={[styles.eyebrow, { marginTop: 20 }]}>Điều ảnh hưởng</Text>
        <View style={styles.tagRow}>
          {tagLabels.map((label) => (
            <View key={label} style={styles.tagChip}>
              <Text style={styles.tagText}>{label}</Text>
            </View>
          ))}
        </View>

        <Text style={[styles.eyebrow, { marginTop: 20 }]}>Bạn viết</Text>
        <Text style={styles.note}>{entry.note || '—'}</Text>
      </View>

      <Pressable
        style={styles.followUpCard}
        onPress={() => navigation.navigate('Player', { kind: 'guided', title: 'Buông một ngày dài', guide: 'Justin Nguyễn', minutes: 12 })}
      >
        <View style={styles.followUpThumb} />
        <View style={{ flex: 1 }}>
          <Text style={styles.eyebrow}>Sau đó bạn đã nghe</Text>
          <Text style={styles.followUpTitle}>Buông một ngày dài · 12 phút</Text>
        </View>
      </Pressable>
    </Screen>
  );
}

const styles = StyleSheet.create({
  topRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  topMuted: { fontFamily: fontFamily.sans, fontSize: 14, color: 'rgba(27,36,32,0.5)' },
  dateLabel: { fontFamily: fontFamily.sansLight, fontSize: 13, color: 'rgba(27,36,32,0.5)', marginTop: 22 },
  moodTitle: { fontFamily: fontFamily.serif, fontSize: 27, color: colors.ink, marginTop: 6 },
  card: { backgroundColor: '#fff', borderRadius: 24, borderWidth: 1, borderColor: 'rgba(27,36,32,0.06)', padding: 20, marginTop: 6 },
  rowBetween: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'baseline' },
  eyebrow: { fontFamily: fontFamily.sans, fontSize: 10.5, letterSpacing: 1, textTransform: 'uppercase', color: 'rgba(27,36,32,0.45)' },
  mutedSm: { fontFamily: fontFamily.sansLight, fontSize: 13, color: 'rgba(27,36,32,0.55)' },
  track: { height: 6, borderRadius: 3, backgroundColor: 'rgba(27,36,32,0.09)', marginTop: 10, overflow: 'hidden' },
  trackFill: { height: 6, borderRadius: 3 },
  tagRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 10 },
  tagChip: { height: 32, paddingHorizontal: 14, borderRadius: 16, backgroundColor: colors.sageTint, alignItems: 'center', justifyContent: 'center' },
  tagText: { fontFamily: fontFamily.sansMedium, fontSize: 13, color: colors.sageTintText },
  note: { fontFamily: fontFamily.sansLight, fontSize: 14.5, lineHeight: 26, color: 'rgba(27,36,32,0.72)', marginTop: 8 },
  followUpCard: { flexDirection: 'row', alignItems: 'center', gap: 14, backgroundColor: '#fff', borderRadius: 22, borderWidth: 1, borderColor: 'rgba(27,36,32,0.06)', padding: 16, marginTop: 12 },
  followUpThumb: { width: 48, height: 48, borderRadius: 14, backgroundColor: '#E4EDF3' },
  followUpTitle: { fontFamily: fontFamily.sansMedium, fontSize: 14.5, color: colors.ink, marginTop: 4 },
});
