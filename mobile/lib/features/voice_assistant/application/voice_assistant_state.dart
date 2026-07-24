enum VoiceAssistantStatus { idle, listening, processing, confirming, speaking }

/// État de l'assistant vocal SENSI. `navigateTo` est un événement à
/// consommer une seule fois par l'écran hôte (voir
/// `VoiceAssistantController.consumeNavigation`).
class VoiceAssistantState {
  const VoiceAssistantState({
    this.status = VoiceAssistantStatus.idle,
    this.responseText,
    this.confirmationText,
    this.navigateTo,
  });

  final VoiceAssistantStatus status;
  final String? responseText;
  final String? confirmationText;
  final String? navigateTo;
}
