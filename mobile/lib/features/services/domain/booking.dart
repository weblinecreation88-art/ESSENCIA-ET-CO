import "package:cloud_firestore/cloud_firestore.dart";

import "service_category.dart";

class Booking {
  const Booking({
    required this.id,
    required this.residentId,
    required this.residentName,
    required this.providerId,
    required this.providerName,
    required this.category,
    required this.date,
    this.status = "confirmed",
  });

  final String id;
  final String residentId;
  final String residentName;
  final String providerId;
  final String providerName;
  final ServiceCategory category;
  final DateTime date;
  final String status;

  factory Booking.fromMap(String id, Map<String, dynamic> map) {
    final date = map["date"] as Timestamp;
    return Booking(
      id: id,
      residentId: map["residentId"] as String? ?? "",
      residentName: map["residentName"] as String? ?? "",
      providerId: map["providerId"] as String? ?? "",
      providerName: map["providerName"] as String? ?? "",
      category: ServiceCategory.fromStorage(map["category"] as String),
      date: date.toDate(),
      status: map["status"] as String? ?? "confirmed",
    );
  }

  Map<String, dynamic> toMap() => {
    "residentId": residentId,
    "residentName": residentName,
    "providerId": providerId,
    "providerName": providerName,
    "category": category.storageValue,
    "date": Timestamp.fromDate(date),
    "status": status,
    "createdAt": FieldValue.serverTimestamp(),
  };
}
