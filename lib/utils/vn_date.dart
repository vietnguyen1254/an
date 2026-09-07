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

String greetingForHour([DateTime? d]) {
  final date = d ?? DateTime.now();
  if (date.hour < 11) return 'Chào buổi sáng';
  if (date.hour < 18) return 'Chào buổi chiều';
  return 'Chào buổi tối';
}
