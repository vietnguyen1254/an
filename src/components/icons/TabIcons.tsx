import React from 'react';
import { View } from 'react-native';

const ACTIVE = '#6F9E8A';
const INACTIVE = 'rgba(27,36,32,0.28)';

export function SkyIcon({ focused }: { focused: boolean }) {
  const c = focused ? ACTIVE : INACTIVE;
  return (
    <View style={{ width: 24, height: 22 }}>
      <View style={{ position: 'absolute', left: 2, bottom: 3, width: 20, height: 9, borderRadius: 5, backgroundColor: c }} />
      <View style={{ position: 'absolute', left: 4, top: 3, width: 10, height: 10, borderRadius: 5, backgroundColor: c }} />
      <View style={{ position: 'absolute', left: 12, top: 5, width: 8, height: 8, borderRadius: 4, backgroundColor: c }} />
    </View>
  );
}

export function HeartIcon({ focused }: { focused: boolean }) {
  const c = focused ? ACTIVE : INACTIVE;
  return (
    <View style={{ width: 24, height: 22, alignItems: 'center' }}>
      <View style={{
        width: 20, height: 20, borderRadius: 10, borderWidth: 2, borderColor: c,
      }} />
      <View style={{ position: 'absolute', left: 11, top: 4, width: 2, height: 7, borderRadius: 1, backgroundColor: c }} />
      <View style={{ position: 'absolute', left: 11, top: 9, width: 6, height: 2, borderRadius: 1, backgroundColor: c }} />
    </View>
  );
}

export function MeditationIcon({ focused }: { focused: boolean }) {
  const c = focused ? ACTIVE : INACTIVE;
  return (
    <View style={{ width: 24, height: 22, justifyContent: 'center', gap: 4 }}>
      <View style={{ width: 18, height: 3, borderRadius: 2, backgroundColor: c }} />
      <View style={{ width: 12, height: 3, borderRadius: 2, backgroundColor: c, marginLeft: 3 }} />
      <View style={{ width: 6, height: 3, borderRadius: 2, backgroundColor: c, marginLeft: 6 }} />
    </View>
  );
}

export function ProfileIcon({ focused }: { focused: boolean }) {
  const c = focused ? ACTIVE : INACTIVE;
  return (
    <View style={{ width: 24, height: 22, alignItems: 'center' }}>
      <View style={{ width: 9, height: 9, borderRadius: 4.5, backgroundColor: c }} />
      <View style={{ marginTop: 2, width: 17, height: 9, borderRadius: 9, borderBottomLeftRadius: 3, borderBottomRightRadius: 3, backgroundColor: c }} />
    </View>
  );
}
