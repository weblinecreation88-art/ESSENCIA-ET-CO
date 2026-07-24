import "voice_command.dart";
import "voice_intent.dart";

/// Analyseur d'intention par mots-clés (français), sans dépendance à un
/// service IA externe — suffisant pour le périmètre MVP de SENSI.
///
/// L'ordre des vérifications compte : les phrases les plus spécifiques sont
/// testées avant les plus génériques (ex. "besoin d'aide" avant un simple
/// "aide").
class VoiceCommandParser {
  static VoiceCommand parse(String rawText) {
    final text = rawText.toLowerCase().trim();

    if (_containsAny(text, [
      "besoin d'aide",
      "besoin daide",
      "ne me sens pas bien",
      "je ne vais pas bien",
    ])) {
      return VoiceCommand(intent: VoiceIntent.needHelp, rawText: rawText);
    }

    if (_containsAny(text, [
      "signale un incident",
      "signalement",
      "où suis-je",
      "ou suis-je",
      "ma position",
      "ma localisation",
    ])) {
      return VoiceCommand(intent: VoiceIntent.unsupported, rawText: rawText);
    }

    if (_containsAny(text, ["urgence", "sos", "secours"])) {
      return VoiceCommand(
        intent: VoiceIntent.openEmergency,
        rawText: rawText,
      );
    }

    final sendMatch = _extractAfterAny(text, [
      "préviens ",
      "previens ",
      "dis à ",
      "dis a ",
      "envoie un message à ",
      "envoie un message a ",
    ]);
    if (sendMatch != null) {
      final (target, body) = _splitTargetAndMessage(sendMatch);
      return VoiceCommand(
        intent: VoiceIntent.sendMessage,
        rawText: rawText,
        targetQuery: target,
        messageBody: body,
      );
    }

    final callMatch = _extractAfterAny(text, [
      "appelle ",
      "appeler ",
      "téléphone à ",
      "telephone a ",
    ]);
    if (callMatch != null) {
      return VoiceCommand(
        intent: VoiceIntent.callRelative,
        rawText: rawText,
        targetQuery: callMatch.trim(),
      );
    }

    if (_containsAny(text, [
      "que dois-je faire aujourd'hui",
      "que dois-je faire aujourd hui",
      "résumé de ma journée",
      "resume de ma journee",
      "mon résumé",
    ])) {
      return VoiceCommand(intent: VoiceIntent.dailySummary, rawText: rawText);
    }

    if (_containsAny(text, [
      "prochain rendez-vous",
      "prochain rendez vous",
    ])) {
      return VoiceCommand(
        intent: VoiceIntent.nextAppointment,
        rawText: rawText,
      );
    }

    if (_containsAny(text, [
      "qu'est-ce que j'ai aujourd'hui",
      "qu est ce que j ai aujourd hui",
      "mon agenda du jour",
      "mes rendez-vous d'aujourd'hui",
    ])) {
      return VoiceCommand(intent: VoiceIntent.todayAgenda, rawText: rawText);
    }

    if (_containsAny(text, [
      "montre mes rendez-vous",
      "montre mes rendez vous",
      "affiche mes visites",
      "ouvre mon agenda",
      "mon agenda",
    ])) {
      return VoiceCommand(intent: VoiceIntent.openAgenda, rawText: rawText);
    }

    if (_containsAny(text, ["lire mes notifications", "mes notifications"])) {
      return VoiceCommand(
        intent: VoiceIntent.readNotifications,
        rawText: rawText,
      );
    }

    if (_containsAny(text, [
      "parler au personnel",
      "contacter le personnel",
      "parler à un professionnel",
    ])) {
      return VoiceCommand(intent: VoiceIntent.talkToStaff, rawText: rawText);
    }

    if (_containsAny(text, [
      "donner mon avis",
      "noter mon accompagnement",
      "je souhaite donner mon avis",
    ])) {
      return VoiceCommand(intent: VoiceIntent.rateCare, rawText: rawText);
    }

    if (_containsAny(text, [
      "tableau de bord",
      "ouvre l'accueil",
      "ouvre laccueil",
      "retour à l'accueil",
    ])) {
      return VoiceCommand(intent: VoiceIntent.openHome, rawText: rawText);
    }

    return VoiceCommand(intent: VoiceIntent.unknown, rawText: rawText);
  }

  static bool _containsAny(String text, List<String> needles) {
    return needles.any(text.contains);
  }

  static String? _extractAfterAny(String text, List<String> prefixes) {
    for (final prefix in prefixes) {
      final index = text.indexOf(prefix);
      if (index != -1) {
        return text.substring(index + prefix.length);
      }
    }
    return null;
  }

  /// Sépare "ma fille que tout va bien" en cible ("ma fille") et message
  /// ("tout va bien"), en coupant sur "que"/"qu'".
  static (String, String?) _splitTargetAndMessage(String text) {
    final match = RegExp(r"\bqu['e]\s*").firstMatch(text);
    if (match == null) return (text.trim(), null);
    final target = text.substring(0, match.start).trim();
    final body = text.substring(match.end).trim();
    return (target, body.isEmpty ? null : body);
  }
}
