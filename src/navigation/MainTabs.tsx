import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { MainTabParamList } from './types';
import { colors } from '../theme/colors';
import { fontFamily } from '../theme/typography';
import { SkyIcon, HeartIcon, MeditationIcon, ProfileIcon } from '../components/icons/TabIcons';
import HomeScreen from '../screens/home/HomeScreen';
import JournalScreen from '../screens/journal/JournalScreen';
import LibraryScreen from '../screens/meditation/LibraryScreen';
import ProfileScreen from '../screens/profile/ProfileScreen';

const Tab = createBottomTabNavigator<MainTabParamList>();

export default function MainTabs() {
  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: colors.sage,
        tabBarInactiveTintColor: 'rgba(27,36,32,0.45)',
        tabBarLabelStyle: { fontFamily: fontFamily.sansMedium, fontSize: 11 },
        tabBarStyle: { height: 84, paddingTop: 10, paddingBottom: 18, backgroundColor: 'rgba(247,249,247,0.96)', borderTopColor: 'rgba(27,36,32,0.07)' },
      }}
    >
      <Tab.Screen name="Home" component={HomeScreen} options={{ tabBarLabel: 'Trời', tabBarIcon: ({ focused }) => <SkyIcon focused={focused} /> }} />
      <Tab.Screen name="Journal" component={JournalScreen} options={{ tabBarLabel: 'Cảm xúc', tabBarIcon: ({ focused }) => <HeartIcon focused={focused} /> }} />
      <Tab.Screen name="Library" component={LibraryScreen} options={{ tabBarLabel: 'Thiền', tabBarIcon: ({ focused }) => <MeditationIcon focused={focused} /> }} />
      <Tab.Screen name="Profile" component={ProfileScreen} options={{ tabBarLabel: 'Bạn', tabBarIcon: ({ focused }) => <ProfileIcon focused={focused} /> }} />
    </Tab.Navigator>
  );
}
