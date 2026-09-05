// "Quiet luxury" palette from the Claude Design export (An copy.dc.html).
// Sky-blue backgrounds so Mây stands over them; jade / rose / lavender accents.
// Dark backgrounds are reserved for meditation sessions and Premium screens.

export const colors = {
  ink: '#1B2420',
  inkSoft: 'rgba(27,36,32,0.7)',
  inkMuted: 'rgba(27,36,32,0.55)',
  inkFaint: 'rgba(27,36,32,0.45)',
  inkHairline: 'rgba(27,36,32,0.08)',

  sage: '#6F9E8A',
  sageDeep: '#4E7A68',
  sageTint: '#E3EDE7',
  sageTintText: '#3D6555',

  lavender: '#A79BC4',
  lavenderTint: '#EDE9F4',
  lavenderTintText: '#4F4468',

  rose: '#F6BDD4',
  blueGray: '#8496B8',
  tan: '#C4A38B',

  premiumMint: '#CFE2DB',
  premiumDarkA: '#20423C',
  premiumDarkB: '#16201E',
  premiumDarkC: '#101817',

  danger: '#8C4A45',

  appBg: '#EAF0F4',
  card: '#FFFFFF',
  cardMuted: 'rgba(255,255,255,0.7)',

  skyTop: '#D7E9F4',
  skyMid: '#B7D4E6',
  skyBottom: '#98BFD6',

  loginTop: '#DCECF5',
  loginMid: '#C3DCEA',
  loginBottom: '#A6CAD9',

  sessionDarkA: '#22423A',
  sessionDarkB: '#16201E',
  sessionDarkC: '#0E1615',

  white: '#FFFFFF',
  onDark: '#FFFFFF',
  onDarkSoft: 'rgba(255,255,255,0.82)',
  onDarkMuted: 'rgba(255,255,255,0.55)',
  onDarkFaint: 'rgba(255,255,255,0.42)',
  onDarkHairline: 'rgba(255,255,255,0.16)',
} as const;

export const moodColors: Record<string, string> = {
  'binh-yen': colors.sage,
  vui: colors.rose,
  'binh-thuong': 'rgba(27,36,32,0.25)',
  'lo-lang': colors.lavender,
  buon: colors.blueGray,
  'kiet-suc': colors.tan,
};

export const moodLabels: Record<string, string> = {
  'binh-yen': 'Bình yên',
  vui: 'Vui',
  'binh-thuong': 'Bình thường',
  'lo-lang': 'Lo lắng',
  buon: 'Buồn',
  'kiet-suc': 'Kiệt sức',
};

export type MoodKey = keyof typeof moodLabels;
