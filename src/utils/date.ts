const WEEKDAYS_VI = ['Chủ Nhật', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'];

export function formatVietnameseDate(d: Date = new Date()): string {
  return `${WEEKDAYS_VI[d.getDay()]}, ${d.getDate()} tháng ${d.getMonth() + 1}`;
}

export function greetingForHour(d: Date = new Date()): string {
  const h = d.getHours();
  if (h < 11) return 'Chào buổi sáng';
  if (h < 18) return 'Chào buổi chiều';
  return 'Chào buổi tối';
}
