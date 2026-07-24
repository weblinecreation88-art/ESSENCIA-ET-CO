/// Intentions reconnues par SENSI, l'assistant vocal, mappées uniquement sur
/// des fonctionnalités déjà existantes de l'application.
enum VoiceIntent {
  openHome,
  openAgenda,
  openEmergency,
  nextAppointment,
  todayAgenda,
  readNotifications,
  dailySummary,
  needHelp,
  callRelative,
  sendMessage,
  talkToStaff,
  rateCare,
  unsupported,
  unknown,
}

/// Actions sensibles nécessitant une confirmation explicite avant exécution.
bool isSensitiveIntent(VoiceIntent intent) =>
    intent == VoiceIntent.callRelative || intent == VoiceIntent.sendMessage;
