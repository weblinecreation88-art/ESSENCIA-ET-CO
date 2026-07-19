import "package:cloud_firestore/cloud_firestore.dart";

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.authorName,
    required this.note,
    this.createdAt,
  });

  final String id;
  final String authorName;
  final String note;
  final DateTime? createdAt;

  factory JournalEntry.fromMap(String id, Map<String, dynamic> map) {
    final createdAt = map["createdAt"] as Timestamp?;
    return JournalEntry(
      id: id,
      authorName: map["authorName"] as String? ?? "",
      note: map["note"] as String? ?? "",
      createdAt: createdAt?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    "authorName": authorName,
    "note": note,
    "createdAt": FieldValue.serverTimestamp(),
  };
}
