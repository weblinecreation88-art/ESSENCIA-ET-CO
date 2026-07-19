import "dart:typed_data";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_storage/firebase_storage.dart";

import "../domain/listing.dart";

/// Encapsule la collection Firestore racine `listings` (annonces publiques
/// de don/vente/location de matériel entre utilisateurs) et l'upload de
/// photo optionnel vers Firebase Storage.
class ListingRepository {
  ListingRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _listings =>
      _firestore.collection("listings");

  Stream<List<Listing>> watchAll() {
    return _listings.orderBy("createdAt", descending: true).snapshots().map(
      (snapshot) => [
        for (final doc in snapshot.docs) Listing.fromMap(doc.id, doc.data()),
      ],
    );
  }

  Future<void> create({
    required String authorUid,
    required String authorName,
    required ListingType type,
    required String title,
    required String description,
    double? price,
    Uint8List? photoBytes,
  }) async {
    String? photoUrl;
    if (photoBytes != null) {
      final ref = _storage.ref(
        "listings/$authorUid/${DateTime.now().millisecondsSinceEpoch}.jpg",
      );
      await ref.putData(photoBytes, SettableMetadata(contentType: "image/jpeg"));
      photoUrl = await ref.getDownloadURL();
    }
    await _listings.add(
      Listing(
        id: "",
        authorUid: authorUid,
        authorName: authorName,
        type: type,
        title: title,
        description: description,
        price: price,
        photoUrl: photoUrl,
      ).toMap(),
    );
  }

  Future<void> delete(String listingId) {
    return _listings.doc(listingId).delete();
  }
}
