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

  /// Recherche un compte par e-mail exact, utilisé pour désigner un tuteur
  /// légal depuis le profil d'un résident.
  Future<UserProfile?> findByEmail(String email) async {
    final snapshot = await _users
        .where("email", isEqualTo: email)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return UserProfile.fromMap(snapshot.docs.first.id, snapshot.docs.first.data());
  }

  Future<void> updateGuardian({
    required String uid,
    required String? guardianUid,
  }) {
    return _users.doc(uid).update({"guardianUid": guardianUid});
  }

  /// Liste les résidents dont `guardianUid` correspond au tuteur donné.
  Stream<List<UserProfile>> watchWardsOf(String guardianUid) {
    return _users
        .where("guardianUid", isEqualTo: guardianUid)
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              UserProfile.fromMap(doc.id, doc.data()),
          ],
        );
  }

  /// Récupère tous les comptes en une seule fois, utilisé par le tableau de
  /// bord Administration pour compter les utilisateurs par rôle.
  Future<List<UserProfile>> fetchAll() async {
    final snapshot = await _users.get();
    return [
      for (final doc in snapshot.docs) UserProfile.fromMap(doc.id, doc.data()),
    ];
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
