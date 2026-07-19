import "dart:typed_data";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_storage/firebase_storage.dart";

import "../domain/photo.dart";

/// Encapsule la sous-collection Firestore `users/{uid}/photos` et l'upload
/// des fichiers correspondants vers Firebase Storage (`photos/{uid}/...`).
class PhotoRepository {
  PhotoRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> _photos(String uid) =>
      _firestore.collection("users").doc(uid).collection("photos");

  Stream<List<Photo>> watchPhotos(String uid) {
    return _photos(uid).orderBy("createdAt", descending: true).snapshots().map(
      (snapshot) => [
        for (final doc in snapshot.docs) Photo.fromMap(doc.id, doc.data()),
      ],
    );
  }

  Future<void> upload({
    required String uid,
    required Uint8List bytes,
    required String caption,
  }) async {
    final ref = _storage.ref(
      "photos/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg",
    );
    await ref.putData(bytes, SettableMetadata(contentType: "image/jpeg"));
    final url = await ref.getDownloadURL();
    await _photos(
      uid,
    ).add(Photo(id: "", url: url, caption: caption).toMap());
  }

  Future<void> delete(String uid, String photoId) {
    return _photos(uid).doc(photoId).delete();
  }
}
