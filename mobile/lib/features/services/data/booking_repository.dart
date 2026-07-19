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
