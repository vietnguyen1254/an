import React from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '../../navigation/types';
import Screen from '../../components/ui/Screen';
import { colors } from '../../theme/colors';
import { fontFamily } from '../../theme/typography';

type Props = NativeStackScreenProps<RootStackParamList, 'MinuteWithJustin'>;

export default function MinuteWithJustinScreen({ navigation }: Props) {
  return (
    <Screen flat={colors.appBg} noPadding contentStyle={{ paddingBottom: 32 }}>
      <View style={styles.topRow}>
        <Pressable onPress={() => navigation.goBack()}><Text style={styles.topMuted}>Đóng</Text></Pressable>
        <Text style={styles.topMuted}>Chia sẻ</Text>
      </View>
      <View style={styles.cover}>
        <View style={styles.playDot} />
      </View>
      <View style={{ paddingHorizontal: 22, marginTop: 24 }}>
        <Text style={styles.eyebrow}>Một phút cùng Justin Nguyễn</Text>
        <Text style={styles.title}>Khi lòng mình ồn ào</Text>
        <View style={styles.authorRow}>
          <View style={styles.authorThumb} />
          <Text style={styles.authorText}>Justin Nguyễn · 90 giây</Text>
        </View>
        <Text style={styles.body}>
          Có những ngày trong đầu bạn ồn như một cái chợ. Bạn không cần dẹp hết tiếng ồn đó. Chỉ cần ngồi xuống, thở
          ba hơi, và để nó đi qua như một cơn mưa rào.
        </Text>
        <Pressable
          style={styles.nextCard}
          onPress={() => navigation.navigate('Player', { kind: 'guided', title: 'Trở về hơi thở', guide: 'Justin Nguyễn', minutes: 12 })}
        >
          <View style={styles.nextThumb} />
          <View style={{ flex: 1 }}>
            <Text style={styles.eyebrow}>Nghe tiếp</Text>
            <Text style={styles.nextTitle}>Trở về hơi thở</Text>
            <Text style={styles.nextMeta}>Thiền dẫn · Justin Nguyễn · 12 phút</Text>
          </View>
        </Pressable>
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  topRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingHorizontal: 22, paddingTop: 14 },
  topMuted: { fontFamily: fontFamily.sans, fontSize: 14, color: 'rgba(27,36,32,0.5)' },
  cover: { marginTop: 18, height: 212, backgroundColor: '#DCE6EC', alignItems: 'center', justifyContent: 'center' },
  playDot: { width: 62, height: 62, borderRadius: 31, backgroundColor: 'rgba(255,255,255,0.9)' },
  eyebrow: { fontFamily: fontFamily.sans, fontSize: 10.5, letterSpacing: 1, textTransform: 'uppercase', color: 'rgba(27,36,32,0.45)' },
  title: { fontFamily: fontFamily.serif, fontSize: 27, lineHeight: 36, color: colors.ink, marginTop: 10 },
  authorRow: { flexDirection: 'row', alignItems: 'center', gap: 10, marginTop: 14 },
  authorThumb: { width: 30, height: 30, borderRadius: 15, backgroundColor: '#DFE7EC' },
  authorText: { fontFamily: fontFamily.sansLight, fontSize: 12.5, color: 'rgba(27,36,32,0.55)' },
  body: { fontFamily: fontFamily.sansLight, fontSize: 15, lineHeight: 28, color: 'rgba(27,36,32,0.72)', marginTop: 20 },
  nextCard: { flexDirection: 'row', alignItems: 'center', gap: 14, backgroundColor: 'rgba(255,255,255,0.8)', borderWidth: 1, borderColor: 'rgba(27,36,32,0.05)', borderRadius: 22, padding: 18, marginTop: 24 },
  nextThumb: { width: 52, height: 52, borderRadius: 16, backgroundColor: colors.sageTint },
  nextTitle: { fontFamily: fontFamily.sansMedium, fontSize: 15, color: colors.ink, marginTop: 5 },
  nextMeta: { fontFamily: fontFamily.sansLight, fontSize: 12.5, color: 'rgba(27,36,32,0.5)', marginTop: 3 },
});
