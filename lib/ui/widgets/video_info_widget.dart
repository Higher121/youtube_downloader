import 'package:flutter/material.dart';
import '../../models/video_info.dart';

class VideoInfoWidget extends StatelessWidget {
  final VideoInfo videoInfo;

  const VideoInfoWidget({super.key, required this.videoInfo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(videoInfo.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text("Duration: ${videoInfo.duration} seconds"),
      ],
    );
  }
}
