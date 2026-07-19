import "package:cloud_firestore/cloud_firestore.dart";

enum NotificationType {
  message,
  booking;

  String get storageValue => name;

  static NotificationType fromStorage(String value) =>
      NotificationType.values.firstWhere((t) => t.name == value);
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    required this.relatedId,
    this.createdAt,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final bool read;
  final String relatedId;
  final DateTime? createdAt;

  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    final createdAt = map["createdAt"] as Timestamp?;
    return AppNotification(
      id: id,
      type: NotificationType.fromStorage(map["type"] as String),
      title: map["title"] as String? ?? "",
      body: map["body"] as String? ?? "",
      read: map["read"] as bool? ?? false,
      relatedId: map["relatedId"] as String? ?? "",
      createdAt: createdAt?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    "type": type.storageValue,
    "title": title,
    "body": body,
    "read": read,
    "relatedId": relatedId,
    "createdAt": FieldValue.serverTimestamp(),
  };
}
