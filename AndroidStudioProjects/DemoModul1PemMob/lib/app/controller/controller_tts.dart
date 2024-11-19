import 'package:flutter_tts/flutter_tts.dart';

class TTSController {
  final FlutterTts flutterTts = FlutterTts();

  TTSController() {
    flutterTts.setLanguage("id-ID"); // Bahasa Indonesia, bisa diganti sesuai keinginan
    flutterTts.setVolume(1.0); // Volume TTS
    flutterTts.setSpeechRate(0.5); // Kecepatan bicara, bisa disesuaikan
    flutterTts.setPitch(1.0); // Nada bicara
  }

  Future<void> speak(String message) async {
    if (message.isNotEmpty) {
      await flutterTts.speak(message);
    }
  }

  void stop() async {
    await flutterTts.stop();
  }
}
