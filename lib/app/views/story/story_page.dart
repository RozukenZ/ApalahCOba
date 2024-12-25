import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart'; // Tambahkan ini untuk direktori penyimpanan
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart'; // Add this for shared preferences

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final List<File> _recordedVideos = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadSavedVideos(); // Load saved videos on app startup
  }

  Future<void> _loadSavedVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedVideosPaths = prefs.getStringList('savedVideos');
    if (savedVideosPaths != null) {
      setState(() {
        _recordedVideos.addAll(savedVideosPaths.map((path) => File(path)));
      });
    }
  }

  Future<void> _recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.camera);

      if (video != null) {
        final savedVideo = await _saveVideoPermanently(File(video.path));
        setState(() {
          _recordedVideos.add(savedVideo);
        });

        // Save the video path to shared preferences
        final prefs = await SharedPreferences.getInstance();
        final List<String> currentVideosPaths = _recordedVideos.map((video) => video.path).toList();
        await prefs.setStringList('savedVideos', currentVideosPaths);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal merekam video: $e')),
      );
    }
  }

  Future<File> _saveVideoPermanently(File video) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final newPath = '${directory.path}/${video.path.split('/').last}';
      final savedVideo = await video.copy(newPath); // Salin file ke lokasi permanen
      print('Video disimpan di: $newPath'); // Debugging: Cetak path baru
      return savedVideo;
    } catch (e) {
      throw Exception('Gagal menyimpan video secara permanen: $e');
    }
  }

  void _playVideo(File video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoFile: video),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Cerita'),
      ),
      body: Column(
        children: [
          ElevatedButton.icon(
            onPressed: _recordVideo,
            icon: const Icon(Icons.videocam),
            label: const Text('Rekam Video'),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _recordedVideos.isNotEmpty
                ? ListView.builder(
              itemCount: _recordedVideos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.play_circle_fill),
                  title: Text('Video ${index + 1}'),
                  subtitle: const Text('Klik untuk memulai'),
                  onTap: () => _playVideo(_recordedVideos[index]),
                );
              },
            )
                : const Center(
              child: Text('Belum ada video yang direkam.'),
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final File videoFile;

  const VideoPlayerScreen({super.key, required this.videoFile});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.file(widget.videoFile);
      await _controller.initialize();
      setState(() {
        _isLoading = false; // Tandai bahwa video sudah siap
      });
      _controller.play(); // Putar video setelah diinisialisasi
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memutar video: $e')),
      );
      Navigator.pop(context); // Kembali jika terjadi kesalahan
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemutar Video'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
      ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
