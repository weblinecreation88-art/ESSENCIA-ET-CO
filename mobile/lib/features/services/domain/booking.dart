import "package:cloud_firestore/cloud_firestore.dart";

import "service_category.dart";

class Booking {
  const Booking({
    required this.id,
    required this.residentId,
    required this.providerId,
    required this.providerName,
    required this.category,
    required this.date,
    this.status = "confirmed",
  });

  final String id;
  final String residentId;
  final String providerId;
  final String providerName;
  final ServiceCategory category;
  final DateTime date;
  final String status;

  Map<String, dynamic> toMap() => {
    "residentId": residentId,
    "providerId": providerId,
    "providerName": providerName,
    "category": category.storageValue,
    "date": Timestamp.fromDate(date),
    "status": status,
    "createdAt": FieldValue.serverTimestamp(),
  };
}
