import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { RootStackParamList } from './types';
import OnboardingScreen from '../screens/onboarding/OnboardingScreen';
import LoginScreen from '../screens/onboarding/LoginScreen';
import MainTabs from './MainTabs';
import MoodCheckInScreen from '../screens/checkin/MoodCheckInScreen';
import SavedScreen from '../screens/checkin/SavedScreen';
import JournalDayDetailScreen from '../screens/journal/DayDetailScreen';
import PlayerScreen from '../screens/meditation/PlayerScreen';
import MinuteWithJustinScreen from '../screens/meditation/MinuteWithJustinScreen';
import GuideProfileScreen from '../screens/meditation/GuideProfileScreen';
import StreaksScreen from '../screens/sky/StreaksScreen';
import RemindersScreen from '../screens/profile/RemindersScreen';
import PrivacyScreen from '../screens/profile/PrivacyScreen';
import PaywallScreen from '../screens/premium/PaywallScreen';
import PlanScreen from '../screens/premium/PlanScreen';
import PaymentSuccessScreen from '../screens/premium/PaymentSuccessScreen';

const Stack = createNativeStackNavigator<RootStackParamList>();

export default function RootNavigator() {
  return (
    <Stack.Navigator
      initialRouteName="Welcome"
      screenOptions={{ headerShown: false }}
    >
      <Stack.Screen name="Welcome" component={OnboardingScreen} />
      <Stack.Screen name="Login" component={LoginScreen} />
      <Stack.Screen name="MainTabs" component={MainTabs} />
      <Stack.Group screenOptions={{ presentation: 'modal' }}>
        <Stack.Screen name="MoodCheckIn" component={MoodCheckInScreen} />
        <Stack.Screen name="Saved" component={SavedScreen} />
        <Stack.Screen name="Player" component={PlayerScreen} />
        <Stack.Screen name="Paywall" component={PaywallScreen} />
        <Stack.Screen name="PaymentSuccess" component={PaymentSuccessScreen} />
      </Stack.Group>
      <Stack.Screen name="MinuteWithJustin" component={MinuteWithJustinScreen} />
      <Stack.Screen name="DayDetail" component={JournalDayDetailScreen} />
      <Stack.Screen name="GuideProfile" component={GuideProfileScreen} />
      <Stack.Screen name="Streaks" component={StreaksScreen} />
      <Stack.Screen name="Reminders" component={RemindersScreen} />
      <Stack.Screen name="Privacy" component={PrivacyScreen} />
      <Stack.Screen name="Plan" component={PlanScreen} />
    </Stack.Navigator>
  );
}
