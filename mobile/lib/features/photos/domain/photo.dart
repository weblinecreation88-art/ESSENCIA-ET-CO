import "package:cloud_firestore/cloud_firestore.dart";

class Photo {
  const Photo({
    required this.id,
    required this.url,
    required this.caption,
    this.createdAt,
  });

  final String id;
  final String url;
  final String caption;
  final DateTime? createdAt;

  factory Photo.fromMap(String id, Map<String, dynamic> map) {
    final createdAt = map["createdAt"] as Timestamp?;
    return Photo(
      id: id,
      url: map["url"] as String,
      caption: map["caption"] as String? ?? "",
      createdAt: createdAt?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    "url": url,
    "caption": caption,
    "createdAt": FieldValue.serverTimestamp(),
  };
}
