import "voice_intent.dart";

/// Résultat de l'analyse d'une phrase reconnue par la commande vocale.
class VoiceCommand {
  const VoiceCommand({
    required this.intent,
    required this.rawText,
    this.targetQuery,
    this.messageBody,
  });

  final VoiceIntent intent;
  final String rawText;

  /// Nom ou lien de parenté cité, ex. "ma fille", "Sophie" — utilisé pour
  /// retrouver un [Proche] pour `callRelative`/`sendMessage`.
  final String? targetQuery;

  /// Texte du message à envoyer, extrait pour `sendMessage`.
  final String? messageBody;
}
