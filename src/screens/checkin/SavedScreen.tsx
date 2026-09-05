import React from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';
import { CommonActions } from '@react-navigation/native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '../../navigation/types';
import Screen from '../../components/ui/Screen';
import { colors } from '../../theme/colors';
import { fontFamily } from '../../theme/typography';
import May from '../../components/May';
import Button from '../../components/ui/Button';
import { useAppStore } from '../../state/store';

type Props = NativeStackScreenProps<RootStackParamList, 'Saved'>;

export default function SavedScreen({ navigation }: Props) {
  const streakDays = useAppStore((s) => s.streakDays);

  const backToSky = () => {
    navigation.dispatch(CommonActions.reset({ index: 0, routes: [{ name: 'MainTabs' }] }));
  };

  return (
    <Screen gradient={[colors.loginTop, colors.loginMid, colors.loginBottom]} scroll={false}>
      <View style={styles.wrap}>
        <View style={styles.mayWrap}>
          <May mood="vui" size={130} />
        </View>
        <Text style={styles.title}>Cảm ơn bạn đã kể.</Text>
        <Text style={styles.subtitle}>
          {streakDays > 0
            ? `${streakDays} ngày liên tục rồi. Trời của bạn vừa có thêm một tia nắng sớm — bạn ghé xem nhé.`
            : 'Trời của bạn vừa có thêm một tia nắng sớm — bạn ghé xem nhé.'}
        </Text>

        <Pressable
          style={styles.suggestCard}
          onPress={() => navigation.navigate('Player', { kind: 'guided', title: 'Buông một ngày dài', guide: 'Justin Nguyễn', minutes: 12 })}
        >
          <Text style={styles.eyebrow}>Gợi ý cho bạn</Text>
          <View style={styles.suggestRow}>
            <View style={styles.suggestThumb} />
            <View>
              <Text style={styles.suggestTitle}>Buông một ngày dài</Text>
              <Text style={styles.suggestSub}>Thiền dẫn · Justin Nguyễn · 12 phút</Text>
            </View>
          </View>
        </Pressable>

        <View style={{ flex: 1 }} />
        <Button
          label="Nghe ngay"
          onPress={() => navigation.navigate('Player', { kind: 'guided', title: 'Buông một ngày dài', guide: 'Justin Nguyễn', minutes: 12 })}
        />
        <Pressable style={{ marginTop: 16 }} onPress={backToSky}>
          <Text style={styles.backText}>Về trời</Text>
        </Pressable>
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  wrap: { flex: 1, paddingHorizontal: 30, paddingTop: 60, paddingBottom: 16 },
  mayWrap: { alignItems: 'center' },
  title: { fontFamily: fontFamily.serif, fontSize: 27, lineHeight: 37, color: colors.ink, textAlign: 'center', marginTop: 24 },
  subtitle: { fontFamily: fontFamily.sansLight, fontSize: 15, lineHeight: 26, color: 'rgba(27,36,32,0.6)', textAlign: 'center', marginTop: 12, maxWidth: 280, alignSelf: 'center' },
  suggestCard: { backgroundColor: 'rgba(255,255,255,0.8)', borderRadius: 22, padding: 18, marginTop: 26, borderWidth: 1, borderColor: 'rgba(255,255,255,0.9)' },
  eyebrow: { fontFamily: fontFamily.sans, fontSize: 11, letterSpacing: 1, textTransform: 'uppercase', color: 'rgba(27,36,32,0.45)' },
  suggestRow: { flexDirection: 'row', alignItems: 'center', gap: 14, marginTop: 12 },
  suggestThumb: { width: 54, height: 54, borderRadius: 16, backgroundColor: colors.sageTint },
  suggestTitle: { fontFamily: fontFamily.sansMedium, fontSize: 15, color: colors.ink },
  suggestSub: { fontFamily: fontFamily.sansLight, fontSize: 12.5, color: 'rgba(27,36,32,0.5)', marginTop: 3 },
  backText: { fontFamily: fontFamily.sans, fontSize: 14, color: 'rgba(27,36,32,0.5)', textAlign: 'center' },
});
