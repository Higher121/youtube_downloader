import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/video_info.dart';

class VideoService {
  static Future<VideoInfo?> fetchVideoInfo(String url) async {
    try {
      print("📡 Sending request to: $apiBaseUrl/get_video_info");
      print("🔗 Video URL: $url");

      final response = await http.post(
        Uri.parse('$apiBaseUrl/get_video_info'),
        body: {'url': url},
      );

      print("📥 Response Code: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return VideoInfo.fromJson(jsonDecode(response.body));
      } else {
        print("❌ Error from API: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching video: $e");
    }
    return null;
  }
}
