import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/video_service.dart';
import '../../services/downloader_service.dart';
import '../widgets/progress_indicator_widget.dart';
import '../../models/video_info.dart';
import '../../core/permissions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedDirectory;
  VideoInfo? _videoInfo;
  bool _isFetching = false;
  bool _isDownloading = false;
  String _selectedQuality = '720p';

  @override
  void initState() {
    super.initState();
    _loadCachedDirectory();
  }

  /// Load saved directory from SharedPreferences
  void _loadCachedDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedDirectory = prefs.getString('selectedDirectory') ?? '';
    });
  }

  Future<void> fetchVideo() async {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please enter a valid URL")),
      );
      return;
    }

    setState(() => _isFetching = true);

    try {
      final info = await VideoService.fetchVideoInfo(_controller.text);

      if (info != null) {
        setState(() {
          _videoInfo = info;
        });
        print("✅ Video Info Updated in UI: ${info.title}");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to get video info.")),
        );
      }
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error fetching video: $e")),
      );
    } finally {
      setState(() => _isFetching = false);
    }
  }

  Future<void> selectDirectory() async {
    bool hasPermission = await PermissionService.requestStoragePermission();

    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission is required!")),
      );
      return;
    }

    String? directory = await FilePicker.platform.getDirectoryPath();
    if (directory != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedDirectory', directory);
      setState(() => _selectedDirectory = directory);
    }
  }

  Future<void> downloadVideo(String url, String fileName) async {
    bool hasPermission = await PermissionService.requestStoragePermission();

    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Storage permission is required to download!")),
      );
      return;
    }

    if (_selectedDirectory == null || _selectedDirectory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a directory first")),
      );
      return;
    }

    setState(() => _isDownloading = true);

    // ✅ Use the return value properly
    bool success = await DownloaderService.startDownload(
      url,
      _selectedDirectory!,
      "$fileName-$_selectedQuality.mp4",
    );

    setState(() => _isDownloading = false);

    // ✅ Show correct message based on success/failure
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(success ? "Download Completed" : "Download Failed")),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inHours)}:"
        "${twoDigits(duration.inMinutes.remainder(60))}:"
        "${twoDigits(duration.inSeconds.remainder(60))}";
  }

  Future<void> pasteFromClipboard() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() {
        _controller.text = data!.text!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YouTube Downloader')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // TextField with Paste Button
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'Enter Video URL',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: pasteFromClipboard,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Fetch Video Button
              ElevatedButton(
                onPressed: _isFetching ? null : fetchVideo,
                child: const Text('Get Video Info'),
              ),

              // Progress Indicator for Fetching
              ProgressIndicatorWidget(isLoading: _isFetching),

              // Display Video Info with Thumbnail
              if (_videoInfo != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Title: ${_videoInfo!.title}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 5),
                      Text("Duration: ${formatDuration(_videoInfo!.duration)}"),
                      const SizedBox(height: 5),
                      if (_videoInfo!.thumbnailUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _videoInfo!.thumbnailUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        const Text("Thumbnail not available"),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Video Quality Selection Dropdown
                DropdownButton<String>(
                  value: _selectedQuality,
                  items: ['144p', '360p', '480p', '720p', '1080p']
                      .map((quality) => DropdownMenuItem(
                            value: quality,
                            child: Text(quality),
                          ))
                      .toList(),
                  onChanged: (newQuality) {
                    setState(() => _selectedQuality = newQuality!);
                  },
                ),

                // Directory Selection
                ElevatedButton(
                  onPressed: selectDirectory,
                  child: Text(_selectedDirectory != null &&
                          _selectedDirectory!.isNotEmpty
                      ? "Selected: $_selectedDirectory"
                      : "Select Download Directory"),
                ),

                // Download Button
                ElevatedButton(
                  onPressed: _isDownloading
                      ? null
                      : () async {
                          // ✅ Wrap in anonymous function
                          bool hasPermission = await PermissionService
                              .requestStoragePermission();
                          if (!hasPermission) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Storage permission required!")),
                            );
                            return;
                          }
                          downloadVideo(
                              _videoInfo!.downloadUrl, _videoInfo!.title);
                        },
                  child: const Text("Download Video"),
                ),

                // Progress Indicator for Downloading
                ProgressIndicatorWidget(isLoading: _isDownloading),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
