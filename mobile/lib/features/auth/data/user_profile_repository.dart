import "package:cloud_firestore/cloud_firestore.dart";

import "../domain/user_profile.dart";
import "../domain/user_role.dart";

/// Encapsule la collection Firestore `users`.
class UserProfileRepository {
  UserProfileRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection("users");

  Future<UserProfile?> fetch(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(uid, doc.data()!);
  }

  Future<void> createProfile({
    required String uid,
    required String email,
    required UserRole role,
  }) {
    return _users.doc(uid).set({
      "uid": uid,
      "email": email,
      "role": role.storageValue,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}
