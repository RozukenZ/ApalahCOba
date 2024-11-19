import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/VoiceNote.dart';
import '../../services/VoiceNote/VoiceNoteService.dart';

class VoiceNoteWidget extends StatefulWidget
{
  const VoiceNoteWidget({Key? key}) : super(key: key);

  @override
  _VoiceNoteWidgetState createState() => _VoiceNoteWidgetState();
}

class _VoiceNoteWidgetState extends State<VoiceNoteWidget>
{
  final VoiceNoteService _voiceNoteService = VoiceNoteService();
  VoiceNote? _currentVoiceNote;
  List<VoiceNote> _voiceNotes = [];
  bool _isPlaying = false;

  @override
  void initState()
  {
    super.initState();
    _loadVoiceNotes();
  }

  Future<void> _loadVoiceNotes() async
  {
    var notes = await _voiceNoteService.getAllVoiceNotes();
    setState(() {
      _voiceNotes = notes;
    });
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Notes'),
      ),
      body: Column(
        children: [
          // Tombol rekam
          IconButton(
            iconSize: 64,
            icon: Icon(
              _voiceNoteService.isRecording
                  ? Icons.stop_circle
                  : Icons.mic,
              color: _voiceNoteService.isRecording ? Colors.red : Colors.blue,
            ),
            onPressed: () async
            {
              if (_voiceNoteService.isRecording)
              {
                var voiceNote = await _voiceNoteService.stopRecording();
                setState(()
                {
                  _currentVoiceNote = voiceNote;
                  if (voiceNote != null)
                  {
                    _voiceNotes.add(voiceNote);
                  }
                });
              } else {
                await _voiceNoteService.startRecording();
                setState(() {});
              }
            },
          ),

          // Daftar voice note
          Expanded(
            child: _voiceNotes.isEmpty
                ? Center(child: Text('No voice notes'))
                : ListView.builder(
              itemCount: _voiceNotes.length,
              itemBuilder: (context, index) {
                var voiceNote = _voiceNotes[index];
                return ListTile(
                  title: Text('Voice Note ${index + 1}'),
                  subtitle: Text(voiceNote.timestamp.toString()),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tombol play
                      IconButton(
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                        onPressed: () async {
                          if (_isPlaying) {
                            await _voiceNoteService.pauseVoiceNote();
                            setState(() {
                              _isPlaying = false;
                            });
                          } else {
                            await _voiceNoteService.playVoiceNote(voiceNote.path);
                            setState(() {
                              _isPlaying = true;
                            });
                          }
                        },
                      ),

                      // Tombol hapus
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _voiceNoteService.deleteVoiceNote(voiceNote.path);
                          setState(() {
                            _voiceNotes.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Pastikan menutup audio player
    _voiceNoteService.pauseVoiceNote();
    super.dispose();
  }
}