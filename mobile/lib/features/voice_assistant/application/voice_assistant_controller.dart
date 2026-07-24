import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:url_launcher/url_launcher.dart";

import "../../agenda/application/agenda_providers.dart";
import "../../agenda/domain/agenda_event.dart";
import "../../auth/application/auth_providers.dart";
import "../../chat/application/chat_providers.dart";
import "../../notifications/application/notification_providers.dart";
import "../../profile/application/profile_providers.dart";
import "../../profile/domain/proche.dart";
import "../data/speech_recognition_service.dart";
import "../data/text_to_speech_service.dart";
import "../domain/voice_command.dart";
import "../domain/voice_command_parser.dart";
import "../domain/voice_intent.dart";
import "voice_assistant_state.dart";

/// Orchestre SENSI : écoute → analyse d'intention → (confirmation si
/// sensible) → exécution via les repositories déjà existants → réponse
/// vocale. Créé et détenu par `VoiceAssistantButton`, pas exposé comme
/// provider global (aucun autre écran n'en a besoin pour l'instant).
class VoiceAssistantController extends ChangeNotifier {
  VoiceAssistantController(this._ref);

  final WidgetRef _ref;
  final _speech = SpeechRecognitionService();
  final _tts = TextToSpeechService();

  VoiceAssistantState state = const VoiceAssistantState();
  Future<void> Function()? _pendingAction;

  void _update(VoiceAssistantState next) {
    state = next;
    notifyListeners();
  }

  /// Consomme l'événement de navigation en attente (à appeler par l'écran
  /// hôte juste après avoir poussé la route).
  void consumeNavigation() {
    if (state.navigateTo == null) return;
    _update(
      VoiceAssistantState(status: state.status, responseText: state.responseText),
    );
  }

  Future<void> startListening() async {
    _update(const VoiceAssistantState(status: VoiceAssistantStatus.listening));
    await _speech.listenOnce(
      onResult: (text) => _handleTranscript(text),
      onDone: () {},
    );
  }

  Future<void> cancel() async {
    await _speech.cancel();
    await _tts.stop();
    _pendingAction = null;
    _update(const VoiceAssistantState());
  }

  Future<void> confirmPendingAction() async {
    final action = _pendingAction;
    _pendingAction = null;
    if (action == null) {
      _update(const VoiceAssistantState());
      return;
    }
    await action();
    await _speakAndFinish("C'est fait.");
  }

  Future<void> cancelPendingAction() async {
    _pendingAction = null;
    await _speakAndFinish("D'accord, action annulée.");
  }

  Future<void> _handleTranscript(String text) async {
    if (text.trim().isEmpty) {
      await _speakAndFinish("Je n'ai rien entendu, réessayez.");
      return;
    }
    _update(VoiceAssistantState(status: VoiceAssistantStatus.processing));
    final command = VoiceCommandParser.parse(text);
    await _execute(command);
  }

  Future<void> _execute(VoiceCommand command) async {
    final uid = _ref.read(authRepositoryProvider).currentUser?.uid;
    if (uid == null) {
      await _speakAndFinish("Vous devez être connecté pour utiliser SENSI.");
      return;
    }

    switch (command.intent) {
      case VoiceIntent.openHome:
        await _speakAndFinish("Voici votre tableau de bord.", navigateTo: "/home");
      case VoiceIntent.openAgenda:
        await _speakAndFinish("Voici votre agenda.", navigateTo: "/agenda");
      case VoiceIntent.openEmergency:
        await _speakAndFinish(
          "Voici les numéros d'urgence.",
          navigateTo: "/emergency",
        );
      case VoiceIntent.talkToStaff:
        await _speakAndFinish(
          "Voici les personnes que vous pouvez contacter.",
          navigateTo: "/chat/new",
        );
      case VoiceIntent.rateCare:
        await _speakAndFinish(
          "Voici l'écran pour donner votre avis.",
          navigateTo: "/satisfaction",
        );
      case VoiceIntent.nextAppointment:
        await _speakNextAppointment(uid);
      case VoiceIntent.todayAgenda:
        await _speakTodayAgenda(uid);
      case VoiceIntent.readNotifications:
        await _speakNotifications(uid);
      case VoiceIntent.dailySummary:
        await _speakDailySummary(uid);
      case VoiceIntent.needHelp:
        await _speakAndFinish(
          "Vous pouvez prévenir un proche en disant par exemple "
          "'Appelle mon fils', ou dire 'Je veux parler au personnel'.",
        );
      case VoiceIntent.callRelative:
        await _prepareCall(uid, command);
      case VoiceIntent.sendMessage:
        await _prepareSendMessage(uid, command);
      case VoiceIntent.unsupported:
        await _speakAndFinish(
          "Cette fonctionnalité n'est pas encore disponible. Vous pouvez "
          "par exemple appeler un proche ou parler au personnel.",
        );
      case VoiceIntent.unknown:
        await _speakAndFinish("Je n'ai pas compris, pouvez-vous reformuler ?");
    }
  }

  Future<void> _speakNextAppointment(String uid) async {
    final events = await _ref.read(agendaRepositoryProvider).watchEvents(uid).first;
    final now = DateTime.now();
    final upcoming = events.where((e) => e.date.isAfter(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    if (upcoming.isEmpty) {
      await _speakAndFinish("Vous n'avez pas de rendez-vous à venir.");
      return;
    }
    final next = upcoming.first;
    await _speakAndFinish(
      "Votre prochain rendez-vous est ${next.title}, le ${_formatDateTime(next.date)}.",
      navigateTo: "/agenda",
    );
  }

  Future<void> _speakTodayAgenda(String uid) async {
    final events = await _ref.read(agendaRepositoryProvider).watchEvents(uid).first;
    final today = _todaysEvents(events);
    if (today.isEmpty) {
      await _speakAndFinish("Vous n'avez rien de prévu aujourd'hui.");
      return;
    }
    final list = today.map((e) => "${e.title} à ${_formatTime(e.date)}").join(", ");
    await _speakAndFinish("Aujourd'hui, vous avez : $list.", navigateTo: "/agenda");
  }

  Future<void> _speakNotifications(String uid) async {
    final notifications = await _ref
        .read(notificationRepositoryProvider)
        .watchNotifications(uid)
        .first;
    final unread = notifications.where((n) => !n.read).toList();
    if (unread.isEmpty) {
      await _speakAndFinish("Vous n'avez aucune nouvelle notification.");
      return;
    }
    final list = unread.take(3).map((n) => n.title).join(", ");
    final plural = unread.length > 1 ? "s" : "";
    await _speakAndFinish(
      "Vous avez ${unread.length} notification$plural non lue$plural : $list.",
      navigateTo: "/notifications",
    );
  }

  Future<void> _speakDailySummary(String uid) async {
    final profile = await _ref.read(userProfileRepositoryProvider).fetch(uid);
    final name = profile?.displayName?.trim();
    final greeting = (name != null && name.isNotEmpty) ? "Bonjour $name" : "Bonjour";

    final events = await _ref.read(agendaRepositoryProvider).watchEvents(uid).first;
    final today = _todaysEvents(events);
    final agendaText = today.isEmpty
        ? "vous n'avez rien de prévu aujourd'hui"
        : "vous avez ${today.length} rendez-vous aujourd'hui, à commencer par "
              "${today.first.title} à ${_formatTime(today.first.date)}";

    final notifications = await _ref
        .read(notificationRepositoryProvider)
        .watchNotifications(uid)
        .first;
    final unreadCount = notifications.where((n) => !n.read).length;
    final notifText = unreadCount == 0
        ? "aucune notification en attente"
        : "$unreadCount notification${unreadCount > 1 ? "s" : ""} non lue${unreadCount > 1 ? "s" : ""}";

    final conversations = await _ref
        .read(chatRepositoryProvider)
        .watchConversations(uid)
        .first;
    final hasUnreadMessage = conversations.any((c) => c.isUnreadFor(uid));
    final messageText = hasUnreadMessage
        ? "et un nouveau message vous attend"
        : "";

    await _speakAndFinish(
      "$greeting. Aujourd'hui, $agendaText. Vous avez $notifText$messageText.",
    );
  }

  Future<Proche?> _matchProche(String uid, String query) async {
    final proches = await _ref.read(procheRepositoryProvider).watch(uid).first;
    if (proches.isEmpty) return null;
    final normalizedQuery = query.toLowerCase();

    final byName = proches
        .where((p) => p.name.isNotEmpty && normalizedQuery.contains(p.name.toLowerCase()))
        .toList();
    if (byName.length == 1) return byName.first;

    const relationKeywords = [
      "petit-fils",
      "petite-fille",
      "fille",
      "fils",
      "épouse",
      "epouse",
      "époux",
      "epoux",
      "mari",
      "femme",
      "aidant",
      "proche",
    ];
    final matchedKeyword = relationKeywords.firstWhere(
      normalizedQuery.contains,
      orElse: () => "",
    );
    if (matchedKeyword.isNotEmpty) {
      final byRelation = proches
          .where((p) => p.relation.toLowerCase().contains(matchedKeyword))
          .toList();
      if (byRelation.length == 1) return byRelation.first;
    }
    return null;
  }

  Future<void> _prepareCall(String uid, VoiceCommand command) async {
    final query = command.targetQuery?.trim();
    if (query == null || query.isEmpty) {
      await _speakAndFinish("Dites par exemple 'Appelle ma fille' ou 'Appelle Sophie'.");
      return;
    }
    final proche = await _matchProche(uid, query);
    if (proche == null) {
      await _speakAndFinish(
        "Je n'ai trouvé personne correspondant dans votre liste de proches.",
        navigateTo: "/profile/family",
      );
      return;
    }
    if (proche.phone == null || proche.phone!.isEmpty) {
      await _speakAndFinish(
        "${proche.name} n'a pas de numéro de téléphone enregistré.",
        navigateTo: "/profile/family",
      );
      return;
    }
    _pendingAction = () async {
      await launchUrl(Uri(scheme: "tel", path: proche.phone));
    };
    _update(
      VoiceAssistantState(
        status: VoiceAssistantStatus.confirming,
        confirmationText: "Voulez-vous appeler ${proche.name} ?",
      ),
    );
  }

  Future<void> _prepareSendMessage(String uid, VoiceCommand command) async {
    final query = command.targetQuery?.trim();
    final body = command.messageBody?.trim();
    if (query == null || query.isEmpty || body == null || body.isEmpty) {
      await _speakAndFinish("Dites par exemple 'Préviens ma fille que tout va bien'.");
      return;
    }
    final proche = await _matchProche(uid, query);
    if (proche == null) {
      await _speakAndFinish(
        "Je n'ai trouvé personne correspondant dans votre liste de proches.",
        navigateTo: "/profile/family",
      );
      return;
    }
    if (proche.email == null || proche.email!.isEmpty) {
      await _speakAndFinish(
        "${proche.name} n'a pas de compte E-sensya & Co lié.",
        navigateTo: "/profile/family",
      );
      return;
    }
    final userProfileRepository = _ref.read(userProfileRepositoryProvider);
    final me = await userProfileRepository.fetch(uid);
    final other = await userProfileRepository.findByEmail(proche.email!);
    if (me == null || other == null) {
      await _speakAndFinish("Aucun compte E-sensya & Co ne correspond à cet e-mail.");
      return;
    }
    _pendingAction = () async {
      final chatId = await _ref.read(chatRepositoryProvider).getOrCreateChat(me, other);
      await _ref
          .read(chatRepositoryProvider)
          .sendMessage(chatId: chatId, senderId: uid, text: body);
    };
    _update(
      VoiceAssistantState(
        status: VoiceAssistantStatus.confirming,
        confirmationText: "Envoyer à ${proche.name} : \"$body\" ?",
      ),
    );
  }

  Future<void> _speakAndFinish(String text, {String? navigateTo}) async {
    _update(
      VoiceAssistantState(status: VoiceAssistantStatus.speaking, responseText: text),
    );
    await _tts.speak(text);
    _update(
      VoiceAssistantState(
        status: VoiceAssistantStatus.idle,
        responseText: text,
        navigateTo: navigateTo,
      ),
    );
  }

  List<AgendaEvent> _todaysEvents(List<AgendaEvent> events) {
    final now = DateTime.now();
    return events
        .where(
          (e) =>
              e.date.year == now.year &&
              e.date.month == now.month &&
              e.date.day == now.day,
        )
        .toList();
  }

  String _formatTime(DateTime date) =>
      "${date.hour.toString().padLeft(2, "0")}h${date.minute.toString().padLeft(2, "0")}";

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    if (isToday) return "aujourd'hui à ${_formatTime(date)}";
    return "le ${date.day}/${date.month} à ${_formatTime(date)}";
  }

  @override
  void dispose() {
    _speech.cancel();
    _tts.stop();
    super.dispose();
  }
}
