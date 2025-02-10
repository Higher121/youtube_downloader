class VideoInfo {
  final String title;
  final String thumbnailUrl;
  final String downloadUrl;
  final Duration duration;

  VideoInfo({
    required this.title,
    required this.thumbnailUrl,
    required this.downloadUrl,
    required this.duration,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      title: json['title'] ?? 'Unknown',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      downloadUrl: json['download_url'] ?? '',
      duration: Duration(seconds: json['duration'] ?? 0), // ✅ Fix for int to Duration
    );
  }
}
