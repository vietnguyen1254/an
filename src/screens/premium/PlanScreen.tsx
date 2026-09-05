import React from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '../../navigation/types';
import Screen from '../../components/ui/Screen';
import { colors } from '../../theme/colors';
import { fontFamily } from '../../theme/typography';
import Button from '../../components/ui/Button';
import { ListRow } from '../../components/ui/Basics';
import { useAppStore } from '../../state/store';

type Props = NativeStackScreenProps<RootStackParamList, 'Plan'>;

const FREE_FEATURES = ['Theo dõi cảm xúc mỗi ngày', 'Bài tập thở cùng Mây', 'Góc nhìn hôm nay', 'Một bài thiền: Buông một ngày dài'];

export default function PlanScreen({ navigation }: Props) {
  const { plan, setPlan } = useAppStore();

  return (
    <Screen flat={colors.appBg}>
      <Pressable onPress={() => navigation.goBack()}><Text style={styles.back}>Quay lại</Text></Pressable>
      <Text style={styles.title}>Gói của bạn</Text>

      {plan === 'free' && (
        <>
          <View style={styles.card}>
            <Text style={styles.eyebrow}>Đang dùng</Text>
            <Text style={styles.cardTitle}>An Free</Text>
            <View style={{ gap: 9, marginTop: 16 }}>
              {FREE_FEATURES.map((f) => (
                <View key={f} style={styles.featureRow}>
                  <View style={styles.featureDot} />
                  <Text style={styles.featureText}>{f}</Text>
                </View>
              ))}
            </View>
          </View>
          <LinearGradient colors={[colors.premiumDarkA, colors.premiumDarkB]} style={styles.lockedCard}>
            <Text style={[styles.eyebrow, { color: 'rgba(255,255,255,0.5)' }]}>Còn khoá</Text>
            <Text style={styles.lockedTitle}>Toàn bộ bài thiền dẫn bởi Justin và Trâm, chuỗi bài theo chủ đề, bài mới mỗi tuần.</Text>
            <View style={{ flexDirection: 'row', gap: 10, marginTop: 18 }}>
              <Pressable style={styles.priceBox} onPress={() => navigation.navigate('Paywall')}>
                <Text style={styles.priceLabel}>Theo tháng</Text>
                <Text style={styles.priceValue}>199.000đ</Text>
              </Pressable>
              <Pressable style={[styles.priceBox, styles.priceBoxHighlight]} onPress={() => navigation.navigate('Paywall')}>
                <Text style={[styles.priceLabel, { color: 'rgba(255,255,255,0.6)' }]}>Theo năm · -29%</Text>
                <Text style={styles.priceValue}>1.699.000đ</Text>
              </Pressable>
            </View>
          </LinearGradient>
          <Button label="Dùng thử 7 ngày miễn phí" onPress={() => navigation.navigate('Paywall')} style={{ marginTop: 20 }} />
          <Text style={styles.fineCenter}>Huỷ trước khi hết hạn thử thì không mất phí.</Text>
        </>
      )}

      {plan === 'monthly' && (
        <>
          <LinearGradient colors={[colors.premiumDarkA, colors.premiumDarkB]} style={styles.activeCard}>
            <Text style={[styles.eyebrow, { color: 'rgba(255,255,255,0.5)' }]}>Đang hoạt động</Text>
            <Text style={styles.activeTitle}>An Premium · theo tháng</Text>
            <Text style={styles.activeMeta}>199.000đ · gia hạn 03/10/2026</Text>
          </LinearGradient>
          <View style={styles.upsellCard}>
            <View style={styles.rowBetween}>
              <Text style={styles.upsellTitle}>Đổi sang gói năm</Text>
              <View style={styles.savePill}><Text style={styles.savePillText}>-29%</Text></View>
            </View>
            <Text style={styles.upsellBody}>1.699.000đ mỗi năm, tính ra 141.500đ một tháng. Phần còn lại của tháng này được trừ vào gói mới.</Text>
            <Button label="Đổi sang gói năm" variant="sage" height={48} onPress={() => setPlan('yearly')} style={{ marginTop: 16 }} />
          </View>
          <View style={styles.listWrap}>
            <ListRow title="Phương thức thanh toán" detail="Apple ID" />
            <ListRow title="Lịch sử thanh toán" isLast />
          </View>
          <Pressable style={styles.cancelBtn} onPress={() => setPlan('free')}>
            <Text style={styles.cancelText}>Huỷ gia hạn</Text>
          </Pressable>
        </>
      )}

      {plan === 'yearly' && (
        <>
          <LinearGradient colors={[colors.premiumDarkA, colors.premiumDarkB]} style={styles.activeCard}>
            <Text style={[styles.eyebrow, { color: 'rgba(255,255,255,0.5)' }]}>Đang hoạt động</Text>
            <Text style={styles.activeTitle}>An Premium · theo năm</Text>
            <Text style={styles.activeMeta}>1.699.000đ · gia hạn 12/03/2027</Text>
          </LinearGradient>
          <View style={styles.listWrap}>
            <ListRow title="Phương thức thanh toán" detail="Apple ID" />
            <ListRow title="Lịch sử thanh toán" isLast />
          </View>
          <View style={styles.noteCard}>
            <Text style={styles.noteText}>
              Nếu bạn huỷ, phần miễn phí vẫn giữ nguyên: theo dõi cảm xúc, bài tập thở, Góc nhìn hôm nay và một bài
              thiền. Nhật ký cảm xúc của bạn không mất.
            </Text>
          </View>
          <Pressable style={styles.cancelBtn} onPress={() => setPlan('free')}>
            <Text style={styles.cancelText}>Huỷ gia hạn</Text>
          </Pressable>
        </>
      )}
    </Screen>
  );
}

const styles = StyleSheet.create({
  back: { fontFamily: fontFamily.sans, fontSize: 14, color: 'rgba(27,36,32,0.5)' },
  title: { fontFamily: fontFamily.serif, fontSize: 27, color: colors.ink, marginTop: 22 },
  card: { backgroundColor: '#fff', borderWidth: 1, borderColor: 'rgba(27,36,32,0.06)', borderRadius: 24, padding: 22, marginTop: 18 },
  eyebrow: { fontFamily: fontFamily.sans, fontSize: 10.5, letterSpacing: 1, textTransform: 'uppercase', color: 'rgba(27,36,32,0.45)' },
  cardTitle: { fontFamily: fontFamily.serif, fontSize: 22, color: colors.ink, marginTop: 8 },
  featureRow: { flexDirection: 'row', gap: 10, alignItems: 'center' },
  featureDot: { width: 5, height: 5, borderRadius: 3, backgroundColor: colors.sage },
  featureText: { fontFamily: fontFamily.sansLight, fontSize: 13.5, color: 'rgba(27,36,32,0.7)' },
  lockedCard: { borderRadius: 24, padding: 22, marginTop: 14 },
  lockedTitle: { fontFamily: fontFamily.serif, fontSize: 21, lineHeight: 29, color: '#fff', marginTop: 8 },
  priceBox: { flex: 1, borderRadius: 16, borderWidth: 1, borderColor: 'rgba(255,255,255,0.18)', padding: 14 },
  priceBoxHighlight: { borderWidth: 2, borderColor: colors.premiumMint, backgroundColor: 'rgba(255,255,255,0.07)' },
  priceLabel: { fontFamily: fontFamily.sans, fontSize: 12, color: 'rgba(255,255,255,0.55)' },
  priceValue: { fontFamily: fontFamily.serif, fontSize: 17, color: '#fff', marginTop: 4 },
  fineCenter: { fontFamily: fontFamily.sansLight, fontSize: 11.5, color: 'rgba(27,36,32,0.45)', marginTop: 12, textAlign: 'center' },
  activeCard: { borderRadius: 24, padding: 22, marginTop: 18 },
  activeTitle: { fontFamily: fontFamily.serif, fontSize: 22, color: '#fff', marginTop: 8 },
  activeMeta: { fontFamily: fontFamily.sansLight, fontSize: 13, color: 'rgba(255,255,255,0.55)', marginTop: 8 },
  upsellCard: { backgroundColor: 'rgba(111,158,138,0.12)', borderWidth: 1, borderColor: 'rgba(111,158,138,0.3)', borderRadius: 24, padding: 20, marginTop: 14 },
  rowBetween: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'baseline' },
  upsellTitle: { fontFamily: fontFamily.sansMedium, fontSize: 15, color: colors.ink },
  savePill: { height: 22, paddingHorizontal: 9, borderRadius: 11, backgroundColor: colors.sage, alignItems: 'center', justifyContent: 'center' },
  savePillText: { fontFamily: fontFamily.sansSemibold, fontSize: 10.5, color: '#fff' },
  upsellBody: { fontFamily: fontFamily.sansLight, fontSize: 13, lineHeight: 22, color: 'rgba(27,36,32,0.65)', marginTop: 8 },
  listWrap: { backgroundColor: '#fff', borderRadius: 22, borderWidth: 1, borderColor: 'rgba(27,36,32,0.06)', marginTop: 14, overflow: 'hidden' },
  noteCard: { backgroundColor: 'rgba(111,158,138,0.1)', borderRadius: 20, padding: 18, marginTop: 16 },
  noteText: { fontFamily: fontFamily.sansLight, fontSize: 13, lineHeight: 22, color: 'rgba(27,36,32,0.7)' },
  cancelBtn: { height: 52, borderRadius: 26, borderWidth: 1, borderColor: 'rgba(27,36,32,0.14)', alignItems: 'center', justifyContent: 'center', marginTop: 20 },
  cancelText: { fontFamily: fontFamily.sans, fontSize: 15, color: 'rgba(27,36,32,0.6)' },
});
