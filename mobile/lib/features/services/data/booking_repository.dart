import "package:cloud_firestore/cloud_firestore.dart";

import "../domain/booking.dart";

/// Encapsule la collection Firestore `bookings`.
class BookingRepository {
  BookingRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<String> create(Booking booking) async {
    final doc = await _firestore.collection("bookings").add(booking.toMap());
    return doc.id;
  }

  /// Réservé aux administrateurs : récupère toutes les réservations en une
  /// seule fois, utilisé par le tableau de bord Administration.
  Future<List<Booking>> fetchAll() async {
    final snapshot = await _firestore.collection("bookings").get();
    return [
      for (final doc in snapshot.docs) Booking.fromMap(doc.id, doc.data()),
    ];
  }

  Stream<List<Booking>> watchForProvider(String providerId) {
    return _firestore
        .collection("bookings")
        .where("providerId", isEqualTo: providerId)
        .orderBy("date")
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs) Booking.fromMap(doc.id, doc.data()),
          ],
        );
  }
}
