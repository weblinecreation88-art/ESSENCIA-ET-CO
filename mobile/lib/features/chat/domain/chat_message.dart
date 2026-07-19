import "package:cloud_firestore/cloud_firestore.dart";

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    this.sentAt,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime? sentAt;

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    final sentAt = map["sentAt"] as Timestamp?;
    return ChatMessage(
      id: id,
      senderId: map["senderId"] as String? ?? "",
      text: map["text"] as String? ?? "",
      sentAt: sentAt?.toDate(),
    );
  }
}
