import 'dart:math' as math;

String formatSize(int bytes) {
  if (bytes <= 0) return '0 B';
  const units = ['B', 'KB', 'MB', 'GB'];
  final digitGroups = (math.log(bytes) / math.log(1024)).floor();
  return '${(bytes / math.pow(1024, digitGroups)).toStringAsFixed(1)} ${units[digitGroups]}';
}
