import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/video_info.dart';

class VideoService {
  static Future<VideoInfo?> fetchVideoInfo(String url) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/get_video_info'),
        body: {'url': url},
      );

      if (response.statusCode == 200) {
        return VideoInfo.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("Error fetching video: $e");
    }
    return null;
  }
}
