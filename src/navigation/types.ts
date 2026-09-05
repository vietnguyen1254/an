export type RootStackParamList = {
  Welcome: undefined;
  MeetMay: undefined;
  Login: undefined;
  MainTabs: undefined;
  MoodCheckIn: undefined;
  Saved: undefined;
  Player: { kind: 'breathing' | 'guided'; title: string; guide?: string; minutes?: number } | undefined;
  MinuteWithJustin: undefined;
  Paywall: undefined;
  Plan: undefined;
  PaymentSuccess: undefined;
  DayDetail: { entryId: string };
  GuideProfile: { guide?: 'justin' | 'tram' } | undefined;
  Reminders: undefined;
  Privacy: undefined;
  Streaks: undefined;
};

export type MainTabParamList = {
  Home: undefined;
  Journal: undefined;
  Library: undefined;
  Profile: undefined;
};
