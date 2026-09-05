import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { CommonActions } from '@react-navigation/native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '../../navigation/types';
import Screen from '../../components/ui/Screen';
import { colors } from '../../theme/colors';
import { fontFamily } from '../../theme/typography';
import May from '../../components/May';
import Button from '../../components/ui/Button';
import { useAppStore } from '../../state/store';

type Props = NativeStackScreenProps<RootStackParamList, 'PaymentSuccess'>;

export default function PaymentSuccessScreen({ navigation }: Props) {
  const plan = useAppStore((s) => s.plan);
  const isYearly = plan === 'yearly';

  const goHome = () => {
    navigation.dispatch(CommonActions.reset({ index: 0, routes: [{ name: 'MainTabs' }] }));
  };

  return (
    <Screen gradient={[colors.loginTop, colors.loginMid, colors.loginBottom]} scroll={false}>
      <View style={styles.wrap}>
        <View style={{ alignItems: 'center' }}>
          <May mood="vui" size={130} />
        </View>
        <View style={{ alignItems: 'center', marginTop: 30 }}>
          <Text style={styles.eyebrow}>An Premium</Text>
          <Text style={styles.title}>Bạn đã mở khoá{'\n'}toàn bộ An.</Text>
          <Text style={styles.subtitle}>
            Gói {isYearly ? 'theo năm · 1.699.000đ' : 'theo tháng · 199.000đ'}. Bảy ngày đầu miễn phí, gia hạn{' '}
            {isYearly ? '12/03/2027' : '03/10/2026'}.
          </Text>
        </View>

        <View style={styles.card}>
          <View style={styles.thumb} />
          <View style={{ flex: 1 }}>
            <Text style={styles.eyebrowSm}>Bắt đầu từ đây</Text>
            <Text style={styles.cardTitle}>Trở về hơi thở</Text>
            <Text style={styles.cardSub}>Thiền dẫn · Justin Nguyễn · 12 phút</Text>
          </View>
        </View>

        <View style={{ flex: 1 }} />
        <Button
          label="Nghe bài đầu tiên"
          onPress={() => navigation.replace('Player', { kind: 'guided', title: 'Trở về hơi thở', guide: 'Justin Nguyễn', minutes: 12 })}
        />
        <Text style={styles.backText} onPress={goHome}>Về trời của tôi</Text>
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  wrap: { flex: 1, paddingHorizontal: 30, paddingTop: 60, paddingBottom: 16 },
  eyebrow: { fontFamily: fontFamily.sans, fontSize: 10.5, letterSpacing: 1.2, textTransform: 'uppercase', color: '#2F5B72' },
  title: { fontFamily: fontFamily.serif, fontSize: 28, lineHeight: 37, color: colors.ink, textAlign: 'center', marginTop: 12 },
  subtitle: { fontFamily: fontFamily.sansLight, fontSize: 14.5, lineHeight: 25, color: 'rgba(27,36,32,0.62)', textAlign: 'center', marginTop: 14, maxWidth: 290 },
  card: { flexDirection: 'row', alignItems: 'center', gap: 14, backgroundColor: 'rgba(255,255,255,0.82)', borderRadius: 22, padding: 18, marginTop: 28, borderWidth: 1, borderColor: 'rgba(255,255,255,0.9)' },
  thumb: { width: 54, height: 54, borderRadius: 16, backgroundColor: colors.sageTint },
  eyebrowSm: { fontFamily: fontFamily.sans, fontSize: 10.5, letterSpacing: 1, textTransform: 'uppercase', color: 'rgba(27,36,32,0.45)' },
  cardTitle: { fontFamily: fontFamily.sansMedium, fontSize: 15, color: colors.ink, marginTop: 5 },
  cardSub: { fontFamily: fontFamily.sansLight, fontSize: 12.5, color: 'rgba(27,36,32,0.5)', marginTop: 3 },
  backText: { fontFamily: fontFamily.sans, fontSize: 14, color: 'rgba(27,36,32,0.5)', textAlign: 'center', marginTop: 16 },
});
