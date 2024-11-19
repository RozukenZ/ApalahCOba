import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/VoiceNote.dart';

class VoiceNoteService
{
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Record _audioRecorder = Record();
  bool _isRecording = false;

  Future<bool> requestPermissions() async
  {
    var micStatus = await Permission.microphone.request();
    var storageStatus = await Permission.storage.request();
    return micStatus.isGranted && storageStatus.isGranted;
  }

  Future<String> _getLocalPath() async
  {
    final directory = await getApplicationDocumentsDirectory();
    final voiceNotesDir = Directory('${directory.path}/voice_notes');
    await voiceNotesDir.create(recursive: true);
    return voiceNotesDir.path;
  }

  Future<VoiceNote?> startRecording() async
  {
    if (!await requestPermissions()) return null;

    final path = await _getLocalPath();
    String fileName = 'voice_note_${DateTime.now().millisecondsSinceEpoch}.mp3';
    final filePath = '$path/$fileName';

    try
    {
      await _audioRecorder.start(
        path: filePath
      );
      _isRecording = true;

      return VoiceNote(
        path: filePath,
        timestamp: DateTime.now(),
      );
    } catch (e)
    {
      print('Error starting recording: $e');
      return null;
    }
  }

  Future<VoiceNote?> stopRecording() async
  {
    if (!_isRecording) return null;

    try
    {
      String? path = await _audioRecorder.stop();
      _isRecording = false;

      if (path != null)
      {
        return VoiceNote(
          path: path,
          timestamp: DateTime.now(),
        );
      }
    } catch (e)
    {
      print('Error stopping recording: $e');
    }

    return null;
  }

  Future<void> playVoiceNote(String path) async
  {
    await _audioPlayer.play(DeviceFileSource(path));
  }

  Future<void> pauseVoiceNote() async
  {
    await _audioPlayer.pause();
  }

  Future<void> deleteVoiceNote(String path) async
  {
    final file = File(path);
    if (await file.exists())
    {
      await file.delete();
    }
  }

  bool get isRecording => _isRecording;

  Future<List<VoiceNote>> getAllVoiceNotes() async
  {
    final path = await _getLocalPath();
    final directory = Directory(path);

    List<VoiceNote> voiceNotes = [];

    if (await directory.exists())
    {
      List<FileSystemEntity> files = directory.listSync();
      for (var file in files)
      {
        if (file is File)
        {
          voiceNotes.add(VoiceNote(
            path: file.path,
            timestamp: File(file.path).lastModifiedSync(),
          ));
        }
      }
    }

    return voiceNotes;
  }
}