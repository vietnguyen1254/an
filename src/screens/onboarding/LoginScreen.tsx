import React from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { CommonActions } from '@react-navigation/native';
import { RootStackParamList } from '../../navigation/types';
import Screen from '../../components/ui/Screen';
import { colors } from '../../theme/colors';
import { fontFamily } from '../../theme/typography';
import { useAppStore } from '../../state/store';

type Props = NativeStackScreenProps<RootStackParamList, 'Login'>;

export default function LoginScreen({ navigation }: Props) {
  const logIn = useAppStore((s) => s.logIn);

  const continueAs = () => {
    logIn();
    navigation.dispatch(CommonActions.reset({ index: 0, routes: [{ name: 'MainTabs' }] }));
  };

  return (
    <Screen gradient={[colors.loginTop, colors.loginMid, colors.loginBottom]} scroll={false}>
      <View style={styles.wrap}>
        <View style={styles.logo} />
        <Text style={styles.title}>Lưu lại hành trình{'\n'}của bạn</Text>
        <Text style={styles.subtitle}>Đăng nhập để cảm xúc và chuỗi ngày của bạn không bị mất khi đổi máy.</Text>

        <View style={{ gap: 11, marginTop: 36 }}>
          <Pressable style={[styles.authBtn, { backgroundColor: colors.ink }]} onPress={continueAs}>
            <View style={[styles.authDot, { backgroundColor: '#F6F8F6' }]} />
            <Text style={[styles.authLabel, { color: '#F6F8F6' }]}>Tiếp tục với Apple</Text>
          </Pressable>
          <Pressable style={[styles.authBtn, styles.authBtnLight]} onPress={continueAs}>
            <View style={[styles.authDot, { backgroundColor: '#C4A38B' }]} />
            <Text style={[styles.authLabel, { color: colors.ink }]}>Tiếp tục với Google</Text>
          </Pressable>
          <Pressable style={[styles.authBtn, styles.authBtnLight]} onPress={continueAs}>
            <View style={[styles.authDot, { backgroundColor: '#5A7FB8' }]} />
            <Text style={[styles.authLabel, { color: colors.ink }]}>Tiếp tục với Facebook</Text>
          </Pressable>
        </View>

        <View style={{ flex: 1 }} />
        <Text style={styles.terms}>
          Tiếp tục nghĩa là bạn đồng ý với Điều khoản{'\n'}và Chính sách riêng tư của An - Thiền và Chữa lành.
        </Text>
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  wrap: { flex: 1, paddingHorizontal: 30, paddingTop: 40, paddingBottom: 24 },
  logo: {
    width: 44, height: 44, borderRadius: 22, backgroundColor: 'rgba(255,255,255,0.9)',
    alignSelf: 'center',
  },
  title: {
    fontFamily: fontFamily.serif, fontSize: 27, lineHeight: 35, color: colors.ink,
    textAlign: 'center', marginTop: 28,
  },
  subtitle: {
    fontFamily: fontFamily.sansLight, fontSize: 14.5, lineHeight: 24, color: 'rgba(27,36,32,0.6)',
    textAlign: 'center', marginTop: 12, maxWidth: 290, alignSelf: 'center',
  },
  authBtn: {
    height: 54, borderRadius: 27, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 11,
  },
  authBtnLight: {
    backgroundColor: '#fff', borderWidth: 1, borderColor: 'rgba(27,36,32,0.1)',
  },
  authDot: { width: 18, height: 18, borderRadius: 9 },
  authLabel: { fontFamily: fontFamily.sansMedium, fontSize: 15.5 },
  terms: {
    fontFamily: fontFamily.sansLight, fontSize: 11.5, lineHeight: 18, color: 'rgba(27,36,32,0.42)',
    textAlign: 'center',
  },
});
