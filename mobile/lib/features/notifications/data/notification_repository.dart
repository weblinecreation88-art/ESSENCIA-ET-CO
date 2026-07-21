import "package:cloud_firestore/cloud_firestore.dart";

import "../domain/app_notification.dart";

/// Encapsule la sous-collection Firestore `users/{uid}/notifications`.
class NotificationRepository {
  NotificationRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _notifications(String uid) =>
      _firestore.collection("users").doc(uid).collection("notifications");

  Stream<List<AppNotification>> watchNotifications(String uid) {
    return _notifications(uid).orderBy("createdAt", descending: true).snapshots().map(
      (snapshot) => [
        for (final doc in snapshot.docs)
          AppNotification.fromMap(doc.id, doc.data()),
      ],
    );
  }

  Stream<int> watchUnreadCount(String uid) {
    return _notifications(
      uid,
    ).where("read", isEqualTo: false).snapshots().map((s) => s.docs.length);
  }

  Future<void> create({
    required String recipientUid,
    required NotificationType type,
    required String title,
    required String body,
    required String relatedId,
  }) {
    return _notifications(recipientUid).add(
      AppNotification(
        id: "",
        type: type,
        title: title,
        body: body,
        read: false,
        relatedId: relatedId,
      ).toMap(),
    );
  }

  Future<void> markAsRead(String uid, String notificationId) {
    return _notifications(uid).doc(notificationId).update({"read": true});
  }

  Future<void> delete(String uid, String notificationId) {
    return _notifications(uid).doc(notificationId).delete();
  }
}
