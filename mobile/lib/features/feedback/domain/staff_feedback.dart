import "package:cloud_firestore/cloud_firestore.dart";

enum FeedbackRating {
  happy,
  neutral,
  unhappy;

  int get score => switch (this) {
    FeedbackRating.happy => 3,
    FeedbackRating.neutral => 2,
    FeedbackRating.unhappy => 1,
  };

  String get emoji => switch (this) {
    FeedbackRating.happy => "😊",
    FeedbackRating.neutral => "😐",
    FeedbackRating.unhappy => "😠",
  };

  String get label => switch (this) {
    FeedbackRating.happy => "Satisfait",
    FeedbackRating.neutral => "Neutre",
    FeedbackRating.unhappy => "Insatisfait",
  };

  String get storageValue => name;

  static FeedbackRating fromStorage(String value) =>
      FeedbackRating.values.firstWhere((r) => r.name == value);
}

class StaffFeedback {
  const StaffFeedback({
    required this.id,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  final String id;
  final FeedbackRating rating;
  final String comment;
  final DateTime? createdAt;

  factory StaffFeedback.fromMap(String id, Map<String, dynamic> map) {
    final createdAt = map["createdAt"] as Timestamp?;
    return StaffFeedback(
      id: id,
      rating: FeedbackRating.fromStorage(map["rating"] as String),
      comment: map["comment"] as String? ?? "",
      createdAt: createdAt?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    "rating": rating.storageValue,
    "comment": comment,
    "createdAt": FieldValue.serverTimestamp(),
  };
}
