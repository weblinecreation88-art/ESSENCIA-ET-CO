import "dart:typed_data";

import "package:firebase_storage/firebase_storage.dart";

/// Encapsule l'upload des photos de profil vers Firebase Storage.
/// Chaque utilisateur ne peut écrire que dans son propre dossier
/// (voir backend/firestore-rules/storage.rules).
class ProfilePhotoRepository {
  ProfilePhotoRepository({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadProfilePhoto({
    required String uid,
    required Uint8List bytes,
  }) async {
    final ref = _storage.ref("profile_photos/$uid.jpg");
    await ref.putData(bytes, SettableMetadata(contentType: "image/jpeg"));
    return ref.getDownloadURL();
  }
}
