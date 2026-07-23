import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";

import "service_category.dart";

enum AppointmentMode {
  video,
  inPerson,
  medicalCenter;

  String get label => switch (this) {
    AppointmentMode.video => "Visio-appel",
    AppointmentMode.inPerson => "En présentiel",
    AppointmentMode.medicalCenter => "Au centre médical",
  };

  String get description => switch (this) {
    AppointmentMode.video => "À distance avec un lien sécurisé",
    AppointmentMode.inPerson => "Au cabinet ou à domicile",
    AppointmentMode.medicalCenter => "Avec l'équipe médicale du centre",
  };

  IconData get icon => switch (this) {
    AppointmentMode.video => Icons.videocam_rounded,
    AppointmentMode.inPerson => Icons.person_pin_circle_rounded,
    AppointmentMode.medicalCenter => Icons.local_hospital_rounded,
  };

  String get storageValue => name;

  static AppointmentMode fromStorage(String? value) {
    if (value == null) return AppointmentMode.inPerson;
    return AppointmentMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => AppointmentMode.inPerson,
    );
  }
}

class Booking {
  const Booking({
    required this.id,
    required this.residentId,
    required this.residentName,
    required this.providerId,
    required this.providerName,
    required this.category,
    required this.date,
    this.specialty,
    this.mode = AppointmentMode.inPerson,
    this.locationDetails,
    this.videoUrl,
    this.status = "confirmed",
  });

  final String id;
  final String residentId;
  final String residentName;
  final String providerId;
  final String providerName;
  final ServiceCategory category;
  final DateTime date;
  final String? specialty;
  final AppointmentMode mode;
  final String? locationDetails;
  final String? videoUrl;
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
      specialty: map["specialty"] as String?,
      mode: AppointmentMode.fromStorage(map["mode"] as String?),
      locationDetails: map["locationDetails"] as String?,
      videoUrl: map["videoUrl"] as String?,
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
    if (specialty != null && specialty!.isNotEmpty) "specialty": specialty,
    "mode": mode.storageValue,
    if (locationDetails != null && locationDetails!.isNotEmpty)
      "locationDetails": locationDetails,
    if (videoUrl != null && videoUrl!.isNotEmpty) "videoUrl": videoUrl,
    "status": status,
    "createdAt": FieldValue.serverTimestamp(),
  };
}
