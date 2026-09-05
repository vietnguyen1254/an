import React, { useState } from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '../../navigation/types';
import Screen from '../../components/ui/Screen';
import { colors } from '../../theme/colors';
import { fontFamily } from '../../theme/typography';
import Button from '../../components/ui/Button';
import { useAppStore } from '../../state/store';

type Props = NativeStackScreenProps<RootStackParamList, 'Paywall'>;

const FEATURES = [
  'Toàn bộ bài thiền dẫn bởi Justin Nguyễn và Trâm Nguyễn',
  'Chuỗi bài theo chủ đề: lo lắng, ngủ, tập trung, biết ơn',
  'Bài mới mỗi tuần',
];

export default function PaywallScreen({ navigation }: Props) {
  const setPlan = useAppStore((s) => s.setPlan);
  const [selected, setSelected] = useState<'yearly' | 'monthly'>('yearly');

  const startTrial = () => {
    setPlan(selected);
    navigation.replace('PaymentSuccess');
  };

  return (
    <Screen flat={colors.premiumDarkC} dark scroll={false}>
      <View style={styles.wrap}>
        <View style={{ flexDirection: 'row', justifyContent: 'flex-end' }}>
          <Pressable style={styles.closeBtn} onPress={() => navigation.goBack()}>
            <Text style={{ color: '#fff' }}>×</Text>
          </Pressable>
        </View>
        <Text style={styles.eyebrow}>An Premium</Text>
        <Text style={styles.title}>Mở khoá toàn bộ{'\n'}không gian chữa lành</Text>

        <View style={{ gap: 14, marginTop: 26 }}>
          {FEATURES.map((f) => (
            <View key={f} style={styles.featureRow}>
              <View style={styles.featureDot} />
              <Text style={styles.featureText}>{f}</Text>
            </View>
          ))}
        </View>

        <View style={{ gap: 10, marginTop: 28 }}>
          <Pressable style={[styles.planCard, selected === 'yearly' && styles.planCardHighlight]} onPress={() => setSelected('yearly')}>
            <View style={styles.savePill}><Text style={styles.savePillText}>TIẾT KIỆM 29%</Text></View>
            <View style={styles.planRow}>
              <Text style={styles.planName}>Theo năm</Text>
              <Text style={styles.planPrice}>1.699.000đ</Text>
            </View>
            <Text style={styles.planSub}>≈ 141.500đ mỗi tháng</Text>
          </Pressable>
          <Pressable style={[styles.planCard, selected === 'monthly' && styles.planCardHighlight]} onPress={() => setSelected('monthly')}>
            <View style={styles.planRow}>
              <Text style={[styles.planName, { color: 'rgba(255,255,255,0.9)' }]}>Theo tháng</Text>
              <Text style={[styles.planPrice, { color: 'rgba(255,255,255,0.9)' }]}>199.000đ</Text>
            </View>
            <Text style={[styles.planSub, { color: 'rgba(255,255,255,0.45)' }]}>huỷ bất cứ lúc nào</Text>
          </Pressable>
        </View>

        <View style={{ flex: 1 }} />
        <Button label="Dùng thử 7 ngày miễn phí" variant="light" onPress={startTrial} />
        <Text style={styles.restore}>Khôi phục mua hàng</Text>
        <Text style={styles.fine}>
          Sau đó 1.699.000đ mỗi năm. Huỷ trước khi hết hạn thử thì không mất phí.{'\n'}Miễn phí vẫn có: theo dõi cảm
          xúc, bài tập thở, Góc nhìn hôm nay và một bài thiền.
        </Text>
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  wrap: { flex: 1, paddingHorizontal: 26, paddingTop: 8, paddingBottom: 20 },
  closeBtn: { width: 30, height: 30, borderRadius: 15, backgroundColor: 'rgba(255,255,255,0.1)', alignItems: 'center', justifyContent: 'center' },
  eyebrow: { fontFamily: fontFamily.sans, fontSize: 10.5, letterSpacing: 1.2, textTransform: 'uppercase', color: 'rgba(255,255,255,0.5)', marginTop: 18 },
  title: { fontFamily: fontFamily.serif, fontSize: 30, lineHeight: 39, color: '#fff', marginTop: 12 },
  featureRow: { flexDirection: 'row', gap: 12, alignItems: 'flex-start' },
  featureDot: { width: 6, height: 6, borderRadius: 3, backgroundColor: colors.premiumMint, marginTop: 8 },
  featureText: { flex: 1, fontFamily: fontFamily.sansLight, fontSize: 14.5, lineHeight: 23, color: 'rgba(255,255,255,0.82)' },
  planCard: { position: 'relative', borderRadius: 22, borderWidth: 1, borderColor: 'rgba(255,255,255,0.16)', padding: 18 },
  planCardHighlight: { borderWidth: 2, borderColor: colors.premiumMint, backgroundColor: 'rgba(255,255,255,0.07)' },
  savePill: { position: 'absolute', right: 18, top: -11, height: 22, paddingHorizontal: 10, borderRadius: 11, backgroundColor: colors.premiumMint, alignItems: 'center', justifyContent: 'center' },
  savePillText: { fontFamily: fontFamily.sansSemibold, fontSize: 10.5, color: '#1B3B33', letterSpacing: 0.4 },
  planRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'baseline' },
  planName: { fontFamily: fontFamily.sansMedium, fontSize: 16, color: '#fff' },
  planPrice: { fontFamily: fontFamily.serif, fontSize: 20, color: '#fff' },
  planSub: { fontFamily: fontFamily.sansLight, fontSize: 12.5, color: 'rgba(255,255,255,0.5)', marginTop: 6 },
  restore: { fontFamily: fontFamily.sans, fontSize: 13, color: 'rgba(255,255,255,0.6)', marginTop: 16, textAlign: 'center' },
  fine: { fontFamily: fontFamily.sansLight, fontSize: 11.5, lineHeight: 18, color: 'rgba(255,255,255,0.42)', marginTop: 12, textAlign: 'center' },
});
