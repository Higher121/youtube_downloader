import 'package:flutter_downloader/flutter_downloader.dart';

class DownloaderService {
  static Future<bool> startDownload(String url, String savePath, String fileName) async {
    try {
      String? taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: savePath,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );

      return taskId != null; // ✅ Return `true` if task ID is created, `false` otherwise.
    } catch (e) {
      print("Download error: $e");
      return false; // ✅ Return `false` on failure
    }
  }
}
