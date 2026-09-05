import React from 'react';
import { View, Text, StyleSheet, Pressable, ScrollView } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { SafeAreaView } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '../../navigation/types';
import { colors } from '../../theme/colors';
import { fontFamily } from '../../theme/typography';
import May from '../../components/May';
import Button from '../../components/ui/Button';
import { useAppStore } from '../../state/store';
import { formatVietnameseDate, greetingForHour } from '../../utils/date';

type Nav = NativeStackNavigationProp<RootStackParamList>;

export default function HomeScreen() {
  const navigation = useNavigation<Nav>();
  const { userName, streakDays, entries } = useAppStore();
  const isFirstDay = entries.length === 0;

  return (
    <View style={{ flex: 1 }}>
      <StatusBar style="dark" />
      <LinearGradient colors={[colors.skyTop, colors.skyMid, colors.skyBottom]} style={styles.bg} />
      <SafeAreaView style={{ flex: 1 }} edges={['top']}>
        <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
          <View style={styles.headerRow}>
            <View>
              <Text style={styles.dateText}>{formatVietnameseDate()}</Text>
              <Text style={styles.greeting}>
                {isFirstDay ? `Chào bạn, ${userName}` : `${greetingForHour()}, ${userName}`}
              </Text>
            </View>
            {!isFirstDay && (
              <Pressable style={styles.streakBadge} onPress={() => navigation.navigate('Streaks')}>
                <Text style={styles.streakBadgeText}>{streakDays}</Text>
              </Pressable>
            )}
          </View>

          <View style={styles.mayStage}>
            <View style={styles.stageGlowBig} />
            <View style={styles.stageGlowSmall} />
            <May mood={isFirstDay ? 'binh-thuong' : 'binh-yen'} size={150} />
          </View>

          <View style={styles.promptCard}>
            <Text style={styles.promptTitle}>
              {isFirstDay ? 'Hôm nay là ngày đầu tiên của bạn ở An.' : 'Hôm nay bạn thế nào?'}
            </Text>
            <Text style={styles.promptSub}>
              {isFirstDay
                ? 'Mây chưa biết gì về bạn cả. Kể cho Mây nghe hôm nay bạn thế nào — mất chừng mười giây.'
                : 'Mây đang chờ bạn kể. Mất chừng mười giây.'}
            </Text>
            <Button
              label={isFirstDay ? 'Ghi cảm xúc đầu tiên' : 'Ghi lại cảm xúc'}
              variant="sage"
              height={50}
              onPress={() => navigation.navigate('MoodCheckIn')}
              style={{ marginTop: 16 }}
            />
          </View>

          <View style={styles.quickRow}>
            <Pressable
              style={styles.quickCard}
              onPress={() => navigation.navigate('Player', { kind: 'breathing', title: 'Thở cùng Mây', minutes: 3 })}
            >
              <View style={[styles.quickIcon, { backgroundColor: colors.sageTint, borderColor: 'rgba(111,158,138,0.3)' }]} />
              <Text style={styles.quickTitle}>Thở 3 phút</Text>
              <Text style={styles.quickSub}>{isFirstDay ? 'cùng Mây' : 'Trước cuộc họp'}</Text>
            </Pressable>
            <Pressable
              style={styles.quickCard}
              onPress={() => (isFirstDay ? navigation.navigate('MinuteWithJustin') : navigation.navigate('Player', { kind: 'breathing', title: 'Nghỉ trưa', minutes: 10 }))}
            >
              <View style={[styles.quickIcon, { backgroundColor: colors.lavenderTint, borderColor: 'rgba(167,155,196,0.35)' }]} />
              <Text style={styles.quickTitle}>{isFirstDay ? 'Góc nhìn' : 'Nghỉ trưa'}</Text>
              <Text style={styles.quickSub}>{isFirstDay ? 'Justin Nguyễn' : '10 phút'}</Text>
            </Pressable>
          </View>

          {!isFirstDay && (
            <>
              <Pressable
                style={styles.suggestCard}
                onPress={() => navigation.navigate('Player', { kind: 'guided', title: 'Trở về hơi thở', guide: 'Justin Nguyễn', minutes: 12 })}
              >
                <View style={styles.suggestThumb} />
                <View style={{ flex: 1 }}>
                  <View style={styles.suggestHeadRow}>
                    <Text style={styles.eyebrow}>Mây gợi ý cho bạn</Text>
                    <View style={styles.premiumPill}>
                      <Text style={styles.premiumPillText}>PREMIUM</Text>
                    </View>
                  </View>
                  <Text style={styles.suggestTitle}>Trở về hơi thở</Text>
                  <Text style={styles.suggestSub}>Thiền dẫn · Justin Nguyễn · 12 phút</Text>
                </View>
              </Pressable>

              <Pressable style={styles.quoteCard} onPress={() => navigation.navigate('MinuteWithJustin')}>
                <Text style={styles.eyebrow}>Góc nhìn hôm nay</Text>
                <Text style={styles.quoteText}>Bình an không phải là hết việc. Là bạn thôi chống lại ngày hôm nay.</Text>
                <View style={styles.quoteAuthorRow}>
                  <View style={styles.quoteAuthorThumb} />
                  <Text style={styles.quoteAuthor}>Justin Nguyễn · 1 phút đọc</Text>
                </View>
              </Pressable>
            </>
          )}
        </ScrollView>
      </SafeAreaView>
    </View>
  );
}

const styles = StyleSheet.create({
  bg: { position: 'absolute', left: 0, right: 0, top: 0, height: 520 },
  scroll: { paddingHorizontal: 22, paddingBottom: 40 },
  headerRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start', marginTop: 8 },
  dateText: { fontFamily: fontFamily.sansLight, fontSize: 13, color: 'rgba(27,36,32,0.5)' },
  greeting: { fontFamily: fontFamily.serif, fontSize: 25, lineHeight: 32, color: colors.ink, marginTop: 4 },
  streakBadge: {
    width: 38, height: 38, borderRadius: 19, backgroundColor: 'rgba(255,255,255,0.7)',
    borderWidth: 1, borderColor: 'rgba(27,36,32,0.07)', alignItems: 'center', justifyContent: 'center',
  },
  streakBadgeText: { fontFamily: fontFamily.sans, fontSize: 13, color: colors.sage },
  mayStage: { height: 260, alignItems: 'center', justifyContent: 'center', marginTop: 6 },
  stageGlowBig: { position: 'absolute', bottom: 24, width: 260, height: 74, borderRadius: 60, backgroundColor: 'rgba(255,255,255,0.35)' },
  stageGlowSmall: { position: 'absolute', top: 20, width: 170, height: 54, borderRadius: 40, backgroundColor: 'rgba(255,255,255,0.4)' },
  promptCard: {
    backgroundColor: 'rgba(255,255,255,0.85)', borderRadius: 26, padding: 22,
    borderWidth: 1, borderColor: 'rgba(255,255,255,0.9)',
  },
  promptTitle: { fontFamily: fontFamily.serif, fontSize: 19, lineHeight: 27, color: colors.ink },
  promptSub: { fontFamily: fontFamily.sansLight, fontSize: 13.5, lineHeight: 21, color: 'rgba(27,36,32,0.55)', marginTop: 6 },
  quickRow: { flexDirection: 'row', gap: 12, marginTop: 14 },
  quickCard: { flex: 1, backgroundColor: 'rgba(255,255,255,0.7)', borderRadius: 20, padding: 16, borderWidth: 1, borderColor: 'rgba(27,36,32,0.05)' },
  quickIcon: { width: 28, height: 28, borderRadius: 14, borderWidth: 1 },
  quickTitle: { fontFamily: fontFamily.sansMedium, fontSize: 14, color: colors.ink, marginTop: 10 },
  quickSub: { fontFamily: fontFamily.sansLight, fontSize: 12, color: 'rgba(27,36,32,0.5)', marginTop: 2 },
  suggestCard: {
    marginTop: 14, backgroundColor: 'rgba(255,255,255,0.85)', borderRadius: 24, padding: 16,
    borderWidth: 1, borderColor: 'rgba(255,255,255,0.9)', flexDirection: 'row', alignItems: 'center', gap: 14,
  },
  suggestThumb: { width: 56, height: 56, borderRadius: 16, backgroundColor: colors.sageTint },
  suggestHeadRow: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  eyebrow: { fontFamily: fontFamily.sans, fontSize: 10.5, letterSpacing: 1, textTransform: 'uppercase', color: 'rgba(27,36,32,0.45)' },
  premiumPill: { height: 18, paddingHorizontal: 7, borderRadius: 9, backgroundColor: colors.sageTint, alignItems: 'center', justifyContent: 'center' },
  premiumPillText: { fontFamily: fontFamily.sansMedium, fontSize: 9.5, letterSpacing: 0.5, color: colors.sageTintText },
  suggestTitle: { fontFamily: fontFamily.sansMedium, fontSize: 15, color: colors.ink, marginTop: 5 },
  suggestSub: { fontFamily: fontFamily.sansLight, fontSize: 12.5, color: 'rgba(27,36,32,0.5)', marginTop: 3 },
  quoteCard: { marginTop: 12, backgroundColor: 'rgba(255,255,255,0.62)', borderRadius: 24, padding: 20 },
  quoteText: { fontFamily: fontFamily.serif, fontSize: 19, lineHeight: 29, color: colors.ink, marginTop: 10 },
  quoteAuthorRow: { flexDirection: 'row', alignItems: 'center', gap: 10, marginTop: 14 },
  quoteAuthorThumb: { width: 28, height: 28, borderRadius: 14, backgroundColor: '#DFE7EC' },
  quoteAuthor: { fontFamily: fontFamily.sansLight, fontSize: 12.5, color: 'rgba(27,36,32,0.55)' },
});
