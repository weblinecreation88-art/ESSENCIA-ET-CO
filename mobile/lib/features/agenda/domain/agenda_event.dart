import "package:cloud_firestore/cloud_firestore.dart";

class AgendaEvent {
  const AgendaEvent({
    required this.id,
    required this.title,
    required this.date,
    this.subtitle,
  });

  final String id;
  final String title;
  final String? subtitle;
  final DateTime date;

  factory AgendaEvent.fromMap(String id, Map<String, dynamic> map) {
    return AgendaEvent(
      id: id,
      title: map["title"] as String? ?? "",
      subtitle: map["subtitle"] as String?,
      date: (map["date"] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    "title": title,
    if (subtitle != null && subtitle!.isNotEmpty) "subtitle": subtitle,
    "date": Timestamp.fromDate(date),
    "createdAt": FieldValue.serverTimestamp(),
  };
}
