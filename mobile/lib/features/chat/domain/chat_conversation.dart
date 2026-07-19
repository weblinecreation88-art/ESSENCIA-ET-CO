import "package:cloud_firestore/cloud_firestore.dart";

import "chat_participant.dart";

class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.participantIds,
    required this.participants,
    this.lastMessage,
    this.lastMessageAt,
  });

  final String id;
  final List<String> participantIds;
  final Map<String, ChatParticipant> participants;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  ChatParticipant? otherParticipant(String myUid) {
    final otherId = participantIds.firstWhere(
      (id) => id != myUid,
      orElse: () => "",
    );
    return participants[otherId];
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
    return ChatConversation(
      id: id,
      participantIds: List<String>.from(map["participantIds"] as List? ?? []),
      participants: participantsMap,
      lastMessage: map["lastMessage"] as String?,
      lastMessageAt: lastMessageAt?.toDate(),
    );
  }
}
