const _weekdaysVi = [
  'Thứ Hai',
  'Thứ Ba',
  'Thứ Tư',
  'Thứ Năm',
  'Thứ Sáu',
  'Thứ Bảy',
  'Chủ Nhật',
];

String formatVietnameseDate([DateTime? d]) {
  final date = d ?? DateTime.now();
  return '${_weekdaysVi[date.weekday - 1]}, ${date.day} tháng ${date.month}';
}

/// Short numeric date for billing/renewal copy — e.g. "12/03/2027".
String formatShortDate(DateTime d) {
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  return '$dd/$mm/${d.year}';
}

/// [d] defaults to [DateTime.now()], which on-device is always the phone's
/// own local time (never the backend's) — Dart's `DateTime.now()` reads the
/// device clock/timezone directly, so this needs no timezone handling of
/// its own.
String greetingForHour([DateTime? d]) {
  final h = (d ?? DateTime.now()).hour;
  if (h >= 5 && h < 11) return 'Chào buổi sáng';
  if (h < 13) return 'Chào buổi trưa';
  if (h < 18) return 'Chào buổi chiều';
  if (h < 22) return 'Chào buổi tối';
  return 'Khuya rồi';
}
