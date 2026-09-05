import { create } from 'zustand';
import { MoodKey } from '../theme/colors';

export type JournalEntry = {
  id: string;
  dateLabel: string; // "Thứ Ba, 1 tháng 9 · 21:12"
  mood: MoodKey;
  intensity: number; // 1-5
  tags: string[];
  note: string;
};

export type PlanTier = 'free' | 'monthly' | 'yearly';

type AppState = {
  hasOnboarded: boolean;
  isLoggedIn: boolean;
  userName: string;
  streakDays: number;
  plan: PlanTier;
  entries: JournalEntry[];

  draftMood: MoodKey;
  draftIntensity: number;
  draftTags: string[];
  draftNote: string;

  completeOnboarding: () => void;
  logIn: () => void;
  setDraftMood: (m: MoodKey) => void;
  toggleDraftTag: (key: string) => void;
  setDraftIntensity: (i: number) => void;
  setDraftNote: (note: string) => void;
  saveDraftEntry: () => void;
  setPlan: (p: PlanTier) => void;
};

export const useAppStore = create<AppState>((set, get) => ({
  hasOnboarded: false,
  isLoggedIn: false,
  userName: 'Linh',
  streakDays: 12,
  plan: 'free',
  entries: [
    {
      id: 'seed-1',
      dateLabel: 'Thứ Ba, 1 tháng 9 · 21:12',
      mood: 'lo-lang',
      intensity: 4,
      tags: ['cong-viec', 'giac-ngu'],
      note: 'Deadline dồn vào cuối tuần, ngủ được có bốn tiếng. Cứ thấy như mình đang chạy mà không tới đâu.',
    },
  ],

  draftMood: 'binh-yen',
  draftIntensity: 3,
  draftTags: ['cong-viec'],
  draftNote: '',

  completeOnboarding: () => set({ hasOnboarded: true }),
  logIn: () => set({ isLoggedIn: true }),
  setDraftMood: (m) => set({ draftMood: m }),
  toggleDraftTag: (key) =>
    set((s) => ({
      draftTags: s.draftTags.includes(key) ? s.draftTags.filter((t) => t !== key) : [...s.draftTags, key],
    })),
  setDraftIntensity: (i) => set({ draftIntensity: Math.max(1, Math.min(5, i)) }),
  setDraftNote: (note) => set({ draftNote: note }),
  saveDraftEntry: () => {
    const s = get();
    const entry: JournalEntry = {
      id: `e-${Date.now()}`,
      dateLabel: 'Hôm nay',
      mood: s.draftMood,
      intensity: s.draftIntensity,
      tags: s.draftTags,
      note: s.draftNote,
    };
    set({ entries: [entry, ...s.entries], streakDays: s.streakDays + 1 });
  },
  setPlan: (p) => set({ plan: p }),
}));

export const MOOD_ORDER: MoodKey[] = ['binh-yen', 'vui', 'binh-thuong', 'lo-lang', 'buon', 'kiet-suc'];

export const TAGS: { key: string; label: string }[] = [
  { key: 'cong-viec', label: 'Công việc' },
  { key: 'gia-dinh', label: 'Gia đình' },
  { key: 'suc-khoe', label: 'Sức khoẻ' },
  { key: 'giac-ngu', label: 'Giấc ngủ' },
  { key: 'tien-bac', label: 'Tiền bạc' },
  { key: 'ban-be', label: 'Bạn bè' },
];

export const INTENSITY_LABELS = ['nhẹ', 'hơi nhẹ', 'vừa', 'khá mạnh', 'rất mạnh'];
