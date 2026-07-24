import "package:speech_to_text/speech_to_text.dart";

/// Encapsule `package:speech_to_text` (reconnaissance vocale, disponible sur
/// Android/iOS et sur Flutter Web via la Web Speech API de Chrome).
class SpeechRecognitionService {
  final SpeechToText _speech = SpeechToText();
  bool _isAvailable = false;

  Future<bool> initialize() async {
    if (_isAvailable) return true;
    _isAvailable = await _speech.initialize();
    return _isAvailable;
  }

  bool get isListening => _speech.isListening;

  /// Démarre une écoute unique et appelle [onResult] avec le texte final
  /// reconnu (ou une chaîne vide si rien n'a été compris).
  Future<void> listenOnce({
    required void Function(String text) onResult,
    required void Function() onDone,
  }) async {
    final available = await initialize();
    if (!available) {
      onResult("");
      onDone();
      return;
    }
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
          onDone();
        }
      },
      listenOptions: SpeechListenOptions(localeId: "fr_FR"),
    );
  }

  Future<void> stop() => _speech.stop();

  Future<void> cancel() => _speech.cancel();
}
