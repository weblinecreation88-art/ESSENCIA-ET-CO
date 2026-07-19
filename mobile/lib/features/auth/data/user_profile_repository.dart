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

  Future<void> updateDisplayName({required String uid, required String displayName}) {
    return _users.doc(uid).update({"displayName": displayName});
  }

  Future<void> updatePhotoUrl({required String uid, required String photoUrl}) {
    return _users.doc(uid).update({"photoUrl": photoUrl});
  }

  Future<void> updatePreferences({
    required String uid,
    required NotificationPreferences preferences,
  }) {
    return _users.doc(uid).update({"preferences": preferences.toMap()});
  }

  /// Liste tous les utilisateurs sauf `excludeUid`, utilisée pour démarrer
  /// une nouvelle conversation.
  Stream<List<UserProfile>> watchAll({required String excludeUid}) {
    return _users.snapshots().map(
      (snapshot) => [
        for (final doc in snapshot.docs)
          if (doc.id != excludeUid) UserProfile.fromMap(doc.id, doc.data()),
      ],
    );
  }

  /// Liste les utilisateurs ayant un rôle donné, utilisée pour lister les
  /// prestataires disponibles à la réservation.
  Stream<List<UserProfile>> watchByRole(UserRole role) {
    return _users
        .where("role", isEqualTo: role.storageValue)
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              UserProfile.fromMap(doc.id, doc.data()),
          ],
        );
  }
}
