import React, { useRef, useState } from 'react';
import { View, Text, StyleSheet, Dimensions, ScrollView, NativeSyntheticEvent, NativeScrollEvent, Pressable } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { SafeAreaView } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '../../navigation/types';
import { colors } from '../../theme/colors';
import { fontFamily } from '../../theme/typography';
import May from '../../components/May';
import Button from '../../components/ui/Button';

const { width: SCREEN_W } = Dimensions.get('window');

type Props = NativeStackScreenProps<RootStackParamList, 'Welcome'>;

export default function OnboardingScreen({ navigation }: Props) {
  const scrollRef = useRef<ScrollView>(null);
  const [page, setPage] = useState(0);

  const onScroll = (e: NativeSyntheticEvent<NativeScrollEvent>) => {
    const p = Math.round(e.nativeEvent.contentOffset.x / SCREEN_W);
    if (p !== page) setPage(p);
  };

  const goNext = () => {
    if (page === 0) scrollRef.current?.scrollTo({ x: SCREEN_W, animated: true });
    else navigation.navigate('Login');
  };

  return (
    <View style={{ flex: 1 }}>
      <StatusBar style="dark" />
      <LinearGradient colors={[colors.skyTop, colors.skyMid, colors.skyBottom]} style={StyleSheet.absoluteFill} />
      <SafeAreaView style={{ flex: 1 }}>
        <ScrollView
          ref={scrollRef}
          horizontal
          pagingEnabled
          showsHorizontalScrollIndicator={false}
          onMomentumScrollEnd={onScroll}
        >
          <Pressable style={{ width: SCREEN_W, flex: 1 }} onPress={goNext}>
            <WelcomePage />
          </Pressable>
          <View style={{ width: SCREEN_W, flex: 1 }}>
            <MeetMayPage onStart={() => navigation.navigate('Login')} />
          </View>
        </ScrollView>
        <View style={styles.dots}>
          <View style={[styles.dot, page === 0 ? styles.dotActive : styles.dotInactive]} />
          <View style={[styles.dot, page === 1 ? styles.dotActive : styles.dotInactive]} />
        </View>
      </SafeAreaView>
    </View>
  );
}

function WelcomePage() {
  return (
    <View style={styles.page}>
      <View style={{ height: 190, alignItems: 'center', justifyContent: 'center' }}>
        <View style={styles.haloOuter}>
          <View style={styles.haloRing} />
          <View style={styles.haloCore} />
        </View>
      </View>
      <Text style={styles.eyebrow}>AN · THIỀN VÀ CHỮA LÀNH</Text>
      <Text style={styles.title}>Chào mừng bạn{'\n'}đến với An</Text>
      <Text style={styles.subtitle}>Một khoảng nhỏ để bạn chậm lại, lắng nghe mình và tìm về sự bình an.</Text>
      <View style={{ flex: 1 }} />
      <Text style={styles.swipeHint}>Lướt sang để tiếp tục</Text>
    </View>
  );
}

function MeetMayPage({ onStart }: { onStart: () => void }) {
  return (
    <View style={styles.page}>
      <View style={{ alignItems: 'center', marginTop: 20 }}>
        <May mood="binh-yen" size={150} />
      </View>
      <Text style={styles.title}>Mình là Mây.</Text>
      <Text style={styles.subtitle}>Mây sẽ đồng hành cùng bạn, lắng nghe cảm xúc và giúp bạn tìm điều mình cần trong từng ngày.</Text>
      <View style={styles.noteCard}>
        <View style={styles.notePh} />
        <Text style={styles.noteText}>Các bài thiền trong An do người thật dẫn. Mây ở bên bạn phần cảm xúc.</Text>
      </View>
      <View style={{ flex: 1 }} />
      <Button label="Bắt đầu cùng mình nhé!" onPress={onStart} />
    </View>
  );
}

const styles = StyleSheet.create({
  page: {
    flex: 1,
    paddingHorizontal: 30,
    paddingTop: 40,
    paddingBottom: 40,
    alignItems: 'center',
  },
  haloOuter: {
    width: 150, height: 150, borderRadius: 75,
    alignItems: 'center', justifyContent: 'center',
    backgroundColor: 'rgba(255,255,255,0.35)',
  },
  haloRing: {
    position: 'absolute', width: 96, height: 96, borderRadius: 48,
    borderWidth: 1, borderColor: 'rgba(47,91,114,0.28)',
  },
  haloCore: {
    width: 52, height: 52, borderRadius: 26, backgroundColor: 'rgba(255,255,255,0.92)',
  },
  eyebrow: {
    fontFamily: fontFamily.sans, fontSize: 14, color: '#2F5B72',
    letterSpacing: 2, textAlign: 'center', marginTop: 10,
  },
  title: {
    fontFamily: fontFamily.serif, fontSize: 30, lineHeight: 40, color: colors.ink,
    textAlign: 'center', marginTop: 18,
  },
  subtitle: {
    fontFamily: fontFamily.sansLight, fontSize: 15, lineHeight: 26, color: 'rgba(27,36,32,0.62)',
    textAlign: 'center', marginTop: 16, maxWidth: 300,
  },
  swipeHint: {
    fontFamily: fontFamily.sansLight, fontSize: 13.5, color: 'rgba(27,36,32,0.5)', textAlign: 'center',
    marginBottom: 8,
  },
  noteCard: {
    flexDirection: 'row', alignItems: 'center', gap: 14,
    backgroundColor: 'rgba(255,255,255,0.72)', borderRadius: 22, padding: 18, marginTop: 26,
    borderWidth: 1, borderColor: 'rgba(255,255,255,0.9)', width: '100%',
  },
  notePh: { width: 44, height: 44, borderRadius: 22, backgroundColor: '#E4EDF3' },
  noteText: { flex: 1, fontFamily: fontFamily.sansLight, fontSize: 13, lineHeight: 21, color: 'rgba(27,36,32,0.7)' },
  dots: {
    flexDirection: 'row', justifyContent: 'center', gap: 8, paddingBottom: 20,
  },
  dot: { height: 4, borderRadius: 2 },
  dotActive: { width: 28, backgroundColor: 'rgba(27,36,32,0.6)' },
  dotInactive: { width: 4, backgroundColor: 'rgba(27,36,32,0.2)' },
});
