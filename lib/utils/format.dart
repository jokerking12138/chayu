/// 中文日期与时间的统一格式化。
String formatChineseDate(DateTime date) {
  const weekdays = <String>['一', '二', '三', '四', '五', '六', '日'];
  final weekday = weekdays[(date.weekday - 1).clamp(0, 6)];
  return '${date.year}年${date.month}月${date.day}日 星期$weekday';
}

String formatShortDate(DateTime date) {
  final h = date.hour.toString().padLeft(2, '0');
  final m = date.minute.toString().padLeft(2, '0');
  return '${date.month}月${date.day}日 $h:$m';
}

String formatClock(int seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

String formatDuration(int seconds) {
  if (seconds < 60) return '$seconds 秒';
  final minutes = seconds ~/ 60;
  final rest = seconds % 60;
  if (rest == 0) return '$minutes 分钟';
  return '$minutes 分 $rest 秒';
}
