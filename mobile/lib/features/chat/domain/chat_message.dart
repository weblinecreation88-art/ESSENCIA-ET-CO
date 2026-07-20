import "package:cloud_firestore/cloud_firestore.dart";

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    this.imageUrl,
    this.sentAt,
  });

  final String id;
  final String senderId;
  final String text;
  final String? imageUrl;
  final DateTime? sentAt;

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    final sentAt = map["sentAt"] as Timestamp?;
    return ChatMessage(
      id: id,
      senderId: map["senderId"] as String? ?? "",
      text: map["text"] as String? ?? "",
      imageUrl: map["imageUrl"] as String?,
      sentAt: sentAt?.toDate(),
    );
  }
}
