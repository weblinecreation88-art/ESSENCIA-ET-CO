import "package:cloud_firestore/cloud_firestore.dart";

enum ListingType {
  don,
  vente,
  location;

  String get label => switch (this) {
    ListingType.don => "Don",
    ListingType.vente => "Vente",
    ListingType.location => "Location",
  };

  String get storageValue => name;

  static ListingType fromStorage(String value) =>
      ListingType.values.firstWhere((t) => t.name == value);
}

class Listing {
  const Listing({
    required this.id,
    required this.authorUid,
    required this.authorName,
    required this.type,
    required this.title,
    required this.description,
    this.price,
    this.photoUrl,
    this.createdAt,
  });

  final String id;
  final String authorUid;
  final String authorName;
  final ListingType type;
  final String title;
  final String description;
  final double? price;
  final String? photoUrl;
  final DateTime? createdAt;

  factory Listing.fromMap(String id, Map<String, dynamic> map) {
    final createdAt = map["createdAt"] as Timestamp?;
    return Listing(
      id: id,
      authorUid: map["authorUid"] as String? ?? "",
      authorName: map["authorName"] as String? ?? "",
      type: ListingType.fromStorage(map["type"] as String),
      title: map["title"] as String? ?? "",
      description: map["description"] as String? ?? "",
      price: (map["price"] as num?)?.toDouble(),
      photoUrl: map["photoUrl"] as String?,
      createdAt: createdAt?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    "authorUid": authorUid,
    "authorName": authorName,
    "type": type.storageValue,
    "title": title,
    "description": description,
    "price": price,
    "photoUrl": photoUrl,
    "createdAt": FieldValue.serverTimestamp(),
  };
}
