import "package:flutter_tts/flutter_tts.dart";

/// Encapsule `package:flutter_tts` (réponse vocale de SENSI en français).
class TextToSpeechService {
  final FlutterTts _tts = FlutterTts();
  bool _configured = false;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _tts.setLanguage("fr-FR");
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(1.0);
    _configured = true;
  }

  Future<void> speak(String text) async {
    await _ensureConfigured();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}
