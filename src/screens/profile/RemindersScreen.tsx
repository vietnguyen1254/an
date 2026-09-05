import React from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '../../navigation/types';
import Screen from '../../components/ui/Screen';
import { colors } from '../../theme/colors';
import { fontFamily } from '../../theme/typography';
import { SwitchRow } from '../../components/ui/Basics';

type Props = NativeStackScreenProps<RootStackParamList, 'Reminders'>;

const NOTIFS = [
  { time: 'An · 07:00', tag: 'bây giờ', body: 'Chào buổi sáng. Ba phút thở trước khi ngày bắt đầu nhé?', opacity: 0.14 },
  { time: 'An · 12:30', tag: 'Góc nhìn hôm nay', body: '"Bình an không phải là hết việc. Là bạn thôi chống lại ngày hôm nay." — Justin', opacity: 0.11 },
  { time: 'An · 21:00', tag: 'trước khi ngủ', body: 'Hôm nay bạn thế nào? Mây đang chờ bạn kể.', opacity: 0.09 },
];

export default function RemindersScreen({ navigation }: Props) {
  return (
    <Screen flat={colors.appBg}>
      <Pressable onPress={() => navigation.goBack()}><Text style={styles.back}>Quay lại</Text></Pressable>
      <Text style={styles.title}>Nhắc nhở</Text>
      <Text style={styles.sub}>Mây nhắc nhẹ, không đòi. Bạn tắt bất cứ lúc nào.</Text>

      <LinearGradient colors={['#2B4A55', '#16242A']} style={styles.lockCard}>
        <Text style={styles.lockEyebrow}>Trên màn hình khoá</Text>
        <View style={{ gap: 9, marginTop: 12 }}>
          {NOTIFS.map((n) => (
            <View key={n.time} style={[styles.notif, { backgroundColor: `rgba(255,255,255,${n.opacity})` }]}>
              <View style={styles.notifTopRow}>
                <Text style={styles.notifTime}>{n.time}</Text>
                <Text style={styles.notifTag}>{n.tag}</Text>
              </View>
              <Text style={styles.notifBody}>{n.body}</Text>
            </View>
          ))}
        </View>
      </LinearGradient>

      <View style={styles.listWrap}>
        <SwitchRow title="Thiền buổi sáng" sub="mỗi ngày" time="07:00" on />
        <SwitchRow title="Thiền buổi tối" sub="mỗi ngày" time="21:00" on />
        <SwitchRow title="Ghi cảm xúc" sub="nếu chưa ghi trong ngày" time="21:30" on />
        <SwitchRow title="Câu nói mỗi ngày" sub="một câu, buổi trưa" on isLast />
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  back: { fontFamily: fontFamily.sans, fontSize: 14, color: 'rgba(27,36,32,0.5)' },
  title: { fontFamily: fontFamily.serif, fontSize: 27, color: colors.ink, marginTop: 22 },
  sub: { fontFamily: fontFamily.sansLight, fontSize: 13.5, lineHeight: 22, color: 'rgba(27,36,32,0.58)', marginTop: 8 },
  lockCard: { borderRadius: 26, padding: 18, marginTop: 20 },
  lockEyebrow: { fontFamily: fontFamily.sans, fontSize: 10.5, letterSpacing: 1, textTransform: 'uppercase', color: 'rgba(255,255,255,0.45)' },
  notif: { borderRadius: 16, padding: 13 },
  notifTopRow: { flexDirection: 'row', justifyContent: 'space-between' },
  notifTime: { fontFamily: fontFamily.sansMedium, fontSize: 12, color: 'rgba(255,255,255,0.85)' },
  notifTag: { fontFamily: fontFamily.sansLight, fontSize: 11, color: 'rgba(255,255,255,0.45)' },
  notifBody: { fontFamily: fontFamily.sansLight, fontSize: 13, lineHeight: 20, color: 'rgba(255,255,255,0.75)', marginTop: 5 },
  listWrap: { backgroundColor: '#fff', borderRadius: 22, borderWidth: 1, borderColor: 'rgba(27,36,32,0.06)', marginTop: 16, overflow: 'hidden' },
});
