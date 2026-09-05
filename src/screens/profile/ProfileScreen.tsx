import React from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '../../navigation/types';
import Screen from '../../components/ui/Screen';
import { colors } from '../../theme/colors';
import { fontFamily } from '../../theme/typography';
import { ListRow, SwitchRow } from '../../components/ui/Basics';
import { useAppStore } from '../../state/store';

type Nav = NativeStackNavigationProp<RootStackParamList>;

const PLAN_LABEL: Record<string, string> = {
  free: 'An Free',
  monthly: 'An Premium · theo tháng',
  yearly: 'An Premium · theo năm',
};

export default function ProfileScreen() {
  const navigation = useNavigation<Nav>();
  const plan = useAppStore((s) => s.plan);

  return (
    <Screen flat={colors.appBg}>
      <Text style={styles.title}>Bạn</Text>

      <View style={styles.profileCard}>
        <View style={styles.avatar} />
        <View style={{ flex: 1 }}>
          <Text style={styles.name}>Nguyễn Thuỳ Linh</Text>
          <Text style={styles.joined}>Tham gia tháng 3, 2026</Text>
        </View>
      </View>

      <Pressable onPress={() => navigation.navigate(plan === 'free' ? 'Paywall' : 'Plan')}>
        <LinearGradient colors={[colors.premiumDarkA, colors.premiumDarkB]} style={styles.planCard}>
          <View style={{ flex: 1 }}>
            <Text style={styles.planEyebrow}>Gói của bạn</Text>
            <Text style={styles.planName}>{PLAN_LABEL[plan]}</Text>
            {plan !== 'free' && <Text style={styles.planMeta}>Gia hạn {plan === 'yearly' ? '12/03/2027' : '03/10/2026'}</Text>}
          </View>
          <View style={styles.manageBtn}>
            <Text style={styles.manageText}>{plan === 'free' ? 'Nâng cấp' : 'Quản lý'}</Text>
          </View>
        </LinearGradient>
      </Pressable>

      <Text style={styles.eyebrow}>Nhắc nhở</Text>
      <Pressable onPress={() => navigation.navigate('Reminders')}>
        <View style={styles.listWrap}>
          <SwitchRow title="Ghi cảm xúc buổi tối" time="21:00" />
          <SwitchRow title="Thở giữa giờ làm" time="15:00" isLast />
        </View>
      </Pressable>

      <Text style={styles.eyebrow}>Cài đặt</Text>
      <View style={styles.listWrap}>
        <ListRow title="Ngôn ngữ" detail="Tiếng Việt" />
        <SwitchRow title="Khoá bằng Face ID" on />
        <Pressable onPress={() => navigation.navigate('Privacy')}>
          <ListRow title="Sao lưu & xuất dữ liệu" />
        </Pressable>
        <Pressable onPress={() => navigation.navigate('Privacy')}>
          <ListRow title="Quyền riêng tư" isLast />
        </Pressable>
      </View>

      <Text style={styles.footer}>Dữ liệu cảm xúc chỉ lưu trên máy bạn.{'\n'}An 1.0 · làm tại Việt Nam</Text>
    </Screen>
  );
}

const styles = StyleSheet.create({
  title: { fontFamily: fontFamily.serif, fontSize: 27, color: colors.ink },
  profileCard: { flexDirection: 'row', alignItems: 'center', gap: 16, backgroundColor: '#fff', borderRadius: 24, borderWidth: 1, borderColor: 'rgba(27,36,32,0.06)', padding: 18, marginTop: 18 },
  avatar: { width: 56, height: 56, borderRadius: 28, backgroundColor: colors.sageTint },
  name: { fontFamily: fontFamily.sansMedium, fontSize: 17, color: colors.ink },
  joined: { fontFamily: fontFamily.sansLight, fontSize: 12.5, color: 'rgba(27,36,32,0.5)', marginTop: 3 },
  planCard: { flexDirection: 'row', alignItems: 'center', gap: 14, borderRadius: 22, padding: 18, marginTop: 14 },
  planEyebrow: { fontFamily: fontFamily.sans, fontSize: 10.5, letterSpacing: 1, textTransform: 'uppercase', color: 'rgba(255,255,255,0.5)' },
  planName: { fontFamily: fontFamily.serif, fontSize: 18, color: '#fff', marginTop: 6 },
  planMeta: { fontFamily: fontFamily.sansLight, fontSize: 12.5, color: 'rgba(255,255,255,0.5)', marginTop: 4 },
  manageBtn: { height: 32, paddingHorizontal: 14, borderRadius: 16, borderWidth: 1, borderColor: 'rgba(255,255,255,0.24)', alignItems: 'center', justifyContent: 'center' },
  manageText: { fontFamily: fontFamily.sans, fontSize: 12.5, color: 'rgba(255,255,255,0.8)' },
  eyebrow: { fontFamily: fontFamily.sans, fontSize: 11, letterSpacing: 1, textTransform: 'uppercase', color: 'rgba(27,36,32,0.45)', marginTop: 26 },
  listWrap: { backgroundColor: '#fff', borderRadius: 22, borderWidth: 1, borderColor: 'rgba(27,36,32,0.06)', marginTop: 12, overflow: 'hidden' },
  footer: { fontFamily: fontFamily.sansLight, fontSize: 12.5, lineHeight: 21, color: 'rgba(27,36,32,0.45)', marginTop: 22, textAlign: 'center' },
});
