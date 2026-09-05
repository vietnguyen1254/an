import React from 'react';
import { View, Text, Pressable, TextInput, StyleSheet } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '../../navigation/types';
import Screen from '../../components/ui/Screen';
import { colors, moodColors, moodLabels } from '../../theme/colors';
import { fontFamily } from '../../theme/typography';
import May from '../../components/May';
import Button from '../../components/ui/Button';
import { useAppStore, MOOD_ORDER, TAGS, INTENSITY_LABELS } from '../../state/store';

type Props = NativeStackScreenProps<RootStackParamList, 'MoodCheckIn'>;

export default function MoodCheckInScreen({ navigation }: Props) {
  const { draftMood, draftIntensity, draftTags, draftNote, setDraftMood, toggleDraftTag, setDraftIntensity, setDraftNote, saveDraftEntry } = useAppStore();

  const onSave = () => {
    saveDraftEntry();
    navigation.replace('Saved');
  };

  const now = new Date();
  const time = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;

  return (
    <Screen flat={colors.appBg}>
      <View style={styles.topRow}>
        <Pressable onPress={() => navigation.goBack()}>
          <Text style={styles.closeText}>Đóng</Text>
        </Pressable>
        <Text style={styles.timeText}>{time}</Text>
      </View>

      <View style={styles.mayWrap}>
        <May mood={draftMood} size={130} />
      </View>

      <Text style={styles.title}>Bạn đang cảm thấy thế nào?</Text>

      <View style={styles.moodGrid}>
        {MOOD_ORDER.map((key) => {
          const on = key === draftMood;
          return (
            <Pressable key={key} style={[styles.moodCell, on && styles.moodCellOn]} onPress={() => setDraftMood(key)}>
              <View style={[styles.moodDot, { backgroundColor: moodColors[key] }]} />
              <Text style={[styles.moodLabel, on && styles.moodLabelOn]}>{moodLabels[key]}</Text>
            </Pressable>
          );
        })}
      </View>

      <View style={styles.rowBetween}>
        <Text style={styles.sectionLabel}>Mức độ</Text>
        <Text style={styles.intensityLabel}>{INTENSITY_LABELS[draftIntensity - 1]}</Text>
      </View>
      <View style={styles.sliderTrackWrap}>
        <View style={styles.sliderTrack}>
          <View style={[styles.sliderFill, { width: `${draftIntensity * 20}%` }]} />
          <View style={[styles.sliderThumb, { left: `${draftIntensity * 20}%` }]} />
        </View>
      </View>
      <View style={styles.intensityBtnRow}>
        <Pressable style={styles.intensityBtn} onPress={() => setDraftIntensity(draftIntensity - 1)}>
          <Text style={styles.intensityBtnText}>Nhẹ hơn</Text>
        </Pressable>
        <Pressable style={styles.intensityBtn} onPress={() => setDraftIntensity(draftIntensity + 1)}>
          <Text style={styles.intensityBtnText}>Mạnh hơn</Text>
        </Pressable>
      </View>

      <Text style={[styles.sectionLabel, { marginTop: 26 }]}>Điều gì ảnh hưởng đến bạn?</Text>
      <View style={styles.tagWrap}>
        {TAGS.map((t) => {
          const on = draftTags.includes(t.key);
          return (
            <Pressable key={t.key} style={[styles.tagChip, on && styles.tagChipOn]} onPress={() => toggleDraftTag(t.key)}>
              <Text style={[styles.tagLabel, on && styles.tagLabelOn]}>{t.label}</Text>
            </Pressable>
          );
        })}
      </View>

      <View style={styles.noteBox}>
        <TextInput
          style={styles.noteInput}
          value={draftNote}
          onChangeText={setDraftNote}
          placeholder="Viết vài dòng cho Mây…"
          placeholderTextColor="rgba(27,36,32,0.35)"
          multiline
        />
      </View>

      <Button label="Lưu cảm xúc" onPress={onSave} style={{ marginTop: 20 }} />
    </Screen>
  );
}

const styles = StyleSheet.create({
  topRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  closeText: { fontFamily: fontFamily.sans, fontSize: 14, color: 'rgba(27,36,32,0.5)' },
  timeText: { fontFamily: fontFamily.sans, fontSize: 13, color: 'rgba(27,36,32,0.4)' },
  mayWrap: { alignItems: 'center', justifyContent: 'center', height: 132, marginTop: 8 },
  title: { fontFamily: fontFamily.serif, fontSize: 26, lineHeight: 34, color: colors.ink, marginTop: 6 },
  moodGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 10, marginTop: 20 },
  moodCell: {
    width: '31.5%', backgroundColor: '#fff', borderRadius: 18, paddingVertical: 16, paddingHorizontal: 8,
    alignItems: 'center', borderWidth: 1, borderColor: 'rgba(27,36,32,0.06)',
  },
  moodCellOn: { backgroundColor: colors.ink, borderColor: colors.ink },
  moodDot: { width: 14, height: 14, borderRadius: 7 },
  moodLabel: { fontFamily: fontFamily.sans, fontSize: 13, color: colors.ink, marginTop: 10 },
  moodLabelOn: { color: '#fff', fontFamily: fontFamily.sansMedium },
  rowBetween: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'baseline', marginTop: 26 },
  sectionLabel: { fontFamily: fontFamily.sansMedium, fontSize: 14, color: colors.ink },
  intensityLabel: { fontFamily: fontFamily.sansLight, fontSize: 13, color: 'rgba(27,36,32,0.5)' },
  sliderTrackWrap: { marginTop: 12, height: 34, justifyContent: 'center' },
  sliderTrack: { height: 6, borderRadius: 3, backgroundColor: 'rgba(27,36,32,0.09)' },
  sliderFill: { position: 'absolute', left: 0, top: 0, bottom: 0, borderRadius: 3, backgroundColor: colors.sage },
  sliderThumb: {
    position: 'absolute', top: -8, width: 22, height: 22, marginLeft: -11, borderRadius: 11, backgroundColor: '#fff',
    borderWidth: 1, borderColor: 'rgba(27,36,32,0.06)',
  },
  intensityBtnRow: { flexDirection: 'row', gap: 8, marginTop: 8 },
  intensityBtn: { flex: 1, height: 36, borderRadius: 18, borderWidth: 1, borderColor: 'rgba(27,36,32,0.1)', alignItems: 'center', justifyContent: 'center' },
  intensityBtnText: { fontFamily: fontFamily.sans, fontSize: 13, color: 'rgba(27,36,32,0.6)' },
  tagWrap: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 12 },
  tagChip: { height: 38, paddingHorizontal: 16, borderRadius: 19, backgroundColor: '#fff', borderWidth: 1, borderColor: 'rgba(27,36,32,0.08)', alignItems: 'center', justifyContent: 'center' },
  tagChipOn: { backgroundColor: colors.sageTint, borderColor: 'rgba(111,158,138,0.4)' },
  tagLabel: { fontFamily: fontFamily.sans, fontSize: 13.5, color: 'rgba(27,36,32,0.65)' },
  tagLabelOn: { color: colors.sageTintText, fontFamily: fontFamily.sansMedium },
  noteBox: { marginTop: 22, backgroundColor: '#fff', borderRadius: 20, borderWidth: 1, borderColor: 'rgba(27,36,32,0.06)', padding: 16, minHeight: 76 },
  noteInput: { fontFamily: fontFamily.sansLight, fontSize: 14, lineHeight: 22, color: 'rgba(27,36,32,0.35)' },
});
