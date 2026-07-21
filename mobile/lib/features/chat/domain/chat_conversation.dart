import "package:cloud_firestore/cloud_firestore.dart";

import "chat_participant.dart";

class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.participantIds,
    required this.participants,
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageSenderId,
    this.lastReadAt = const {},
  });

  final String id;
  final List<String> participantIds;
  final Map<String, ChatParticipant> participants;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastMessageSenderId;
  final Map<String, DateTime> lastReadAt;

  ChatParticipant? otherParticipant(String myUid) {
    final otherId = participantIds.firstWhere(
      (id) => id != myUid,
      orElse: () => "",
    );
    return participants[otherId];
  }

  /// Vrai si le dernier message n'a pas été envoyé par `myUid` et n'a pas
  /// encore été lu par lui.
  bool isUnreadFor(String myUid) {
    if (lastMessageAt == null || lastMessageSenderId == myUid) return false;
    final read = lastReadAt[myUid];
    return read == null || read.isBefore(lastMessageAt!);
  }

  factory ChatConversation.fromMap(String id, Map<String, dynamic> map) {
    final participantsMap = <String, ChatParticipant>{};
    final rawParticipants = map["participants"] as Map<String, dynamic>? ?? {};
    for (final entry in rawParticipants.entries) {
      participantsMap[entry.key] = ChatParticipant.fromMap(
        entry.key,
        entry.value as Map<String, dynamic>,
      );
    }
    final lastMessageAt = map["lastMessageAt"] as Timestamp?;
    final rawLastReadAt = map["lastReadAt"] as Map<String, dynamic>? ?? {};
    final lastReadAtMap = <String, DateTime>{
      for (final entry in rawLastReadAt.entries)
        if (entry.value is Timestamp)
          entry.key: (entry.value as Timestamp).toDate(),
    };
    return ChatConversation(
      id: id,
      participantIds: List<String>.from(map["participantIds"] as List? ?? []),
      participants: participantsMap,
      lastMessage: map["lastMessage"] as String?,
      lastMessageAt: lastMessageAt?.toDate(),
      lastMessageSenderId: map["lastMessageSenderId"] as String?,
      lastReadAt: lastReadAtMap,
    );
  }
}
