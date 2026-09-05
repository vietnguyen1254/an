import React, { useState } from 'react';
import { View, Text, Pressable, TextInput, StyleSheet } from 'react-native';
import { CommonActions } from '@react-navigation/native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '../../navigation/types';
import Screen from '../../components/ui/Screen';
import { colors } from '../../theme/colors';
import { fontFamily } from '../../theme/typography';
import { ListRow, ToggleSwitch } from '../../components/ui/Basics';

type Props = NativeStackScreenProps<RootStackParamList, 'Privacy'>;

export default function PrivacyScreen({ navigation }: Props) {
  const [confirming, setConfirming] = useState(false);
  const [text, setText] = useState('');

  const confirmDelete = () => {
    navigation.dispatch(CommonActions.reset({ index: 0, routes: [{ name: 'Welcome' }] }));
  };

  return (
    <Screen flat={colors.appBg} scroll={!confirming}>
      <Pressable onPress={() => navigation.goBack()}><Text style={styles.back}>Quay lại</Text></Pressable>
      <Text style={styles.title}>Riêng tư & dữ liệu</Text>

      <View style={styles.introCard}>
        <Text style={styles.introText}>
          Nhật ký cảm xúc của bạn được lưu trên máy và trong tài khoản của bạn. An không bán dữ liệu và không dùng nội
          dung bạn viết để quảng cáo.
        </Text>
      </View>

      <View style={styles.listWrap}>
        <View style={styles.row}>
          <View style={{ flex: 1 }}>
            <Text style={styles.rowTitle}>Xuất dữ liệu</Text>
            <Text style={styles.rowSub}>gửi file CSV về email của bạn</Text>
          </View>
        </View>
        <View style={[styles.row, styles.rowBorder]}>
          <Text style={styles.rowTitle}>Sao lưu iCloud</Text>
          <ToggleSwitch on />
        </View>
        <ListRow title="Chính sách riêng tư" isLast />
      </View>

      <View style={styles.dangerCard}>
        <Text style={styles.dangerTitle}>Xoá tài khoản</Text>
        <Text style={styles.dangerBody}>
          Toàn bộ nhật ký cảm xúc, chuỗi ngày và trời của bạn sẽ bị xoá. Việc này không thể hoàn lại. Gói Premium cần
          huỷ riêng trong App Store.
        </Text>
        {!confirming && (
          <Pressable onPress={() => setConfirming(true)} style={{ marginTop: 14 }}>
            <Text style={[styles.dangerTitle, { fontFamily: fontFamily.sans, fontSize: 14 }]}>Xoá tài khoản của bạn…</Text>
          </Pressable>
        )}
      </View>

      {confirming && (
        <View style={styles.confirmSheet}>
          <Text style={styles.confirmTitle}>Xoá tài khoản của bạn?</Text>
          <Text style={styles.confirmBody}>Nhập XOA để xác nhận.</Text>
          <TextInput
            style={styles.confirmInput}
            value={text}
            onChangeText={setText}
            placeholder="XOA"
            placeholderTextColor="rgba(27,36,32,0.35)"
            autoCapitalize="characters"
          />
          <View style={styles.confirmBtnRow}>
            <Pressable style={styles.keepBtn} onPress={() => setConfirming(false)}>
              <Text style={styles.keepText}>Giữ lại</Text>
            </Pressable>
            <Pressable
              style={[styles.deleteBtn, text.trim().toUpperCase() !== 'XOA' && { opacity: 0.4 }]}
              disabled={text.trim().toUpperCase() !== 'XOA'}
              onPress={confirmDelete}
            >
              <Text style={styles.deleteText}>Xoá</Text>
            </Pressable>
          </View>
        </View>
      )}
    </Screen>
  );
}

const styles = StyleSheet.create({
  back: { fontFamily: fontFamily.sans, fontSize: 14, color: 'rgba(27,36,32,0.5)' },
  title: { fontFamily: fontFamily.serif, fontSize: 27, color: colors.ink, marginTop: 22 },
  introCard: { backgroundColor: 'rgba(111,158,138,0.1)', borderRadius: 22, padding: 18, marginTop: 18 },
  introText: { fontFamily: fontFamily.sansLight, fontSize: 13.5, lineHeight: 22, color: 'rgba(27,36,32,0.7)' },
  listWrap: { backgroundColor: '#fff', borderRadius: 22, borderWidth: 1, borderColor: 'rgba(27,36,32,0.06)', marginTop: 16, overflow: 'hidden' },
  row: { flexDirection: 'row', alignItems: 'center', paddingHorizontal: 18, paddingVertical: 16 },
  rowBorder: { borderBottomWidth: 1, borderBottomColor: 'rgba(27,36,32,0.05)', borderTopWidth: 1, borderTopColor: 'rgba(27,36,32,0.05)' },
  rowTitle: { flex: 1, fontFamily: fontFamily.sans, fontSize: 15, color: colors.ink },
  rowSub: { fontFamily: fontFamily.sansLight, fontSize: 12, color: 'rgba(27,36,32,0.5)', marginTop: 2 },
  dangerCard: { backgroundColor: '#fff', borderRadius: 22, borderWidth: 1, borderColor: 'rgba(27,36,32,0.06)', padding: 18, marginTop: 14 },
  dangerTitle: { fontFamily: fontFamily.sansMedium, fontSize: 15, color: colors.danger },
  dangerBody: { fontFamily: fontFamily.sansLight, fontSize: 13, lineHeight: 22, color: 'rgba(27,36,32,0.6)', marginTop: 8 },
  confirmSheet: { backgroundColor: '#fff', borderRadius: 26, padding: 22, marginTop: 16 },
  confirmTitle: { fontFamily: fontFamily.serif, fontSize: 19, color: colors.ink },
  confirmBody: { fontFamily: fontFamily.sansLight, fontSize: 13, lineHeight: 22, color: 'rgba(27,36,32,0.6)', marginTop: 8 },
  confirmInput: { height: 48, borderRadius: 16, borderWidth: 1, borderColor: 'rgba(27,36,32,0.1)', backgroundColor: '#FAFBFC', marginTop: 12, paddingHorizontal: 16, fontFamily: fontFamily.sans, fontSize: 16, color: colors.ink },
  confirmBtnRow: { flexDirection: 'row', gap: 10, marginTop: 14 },
  keepBtn: { flex: 1, height: 48, borderRadius: 24, borderWidth: 1, borderColor: 'rgba(27,36,32,0.12)', alignItems: 'center', justifyContent: 'center' },
  keepText: { fontFamily: fontFamily.sans, fontSize: 15, color: 'rgba(27,36,32,0.6)' },
  deleteBtn: { flex: 1, height: 48, borderRadius: 24, backgroundColor: colors.danger, alignItems: 'center', justifyContent: 'center' },
  deleteText: { fontFamily: fontFamily.sansMedium, fontSize: 15, color: '#fff' },
});
