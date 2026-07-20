import "dart:typed_data";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_storage/firebase_storage.dart";

import "../../auth/domain/user_profile.dart";
import "../domain/chat_conversation.dart";
import "../domain/chat_message.dart";

/// Encapsule les collections Firestore `chats` et `chats/{id}/messages`.
class ChatRepository {
  ChatRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection("chats");

  /// Identifiant déterministe pour une paire d'utilisateurs, indépendant de
  /// l'ordre, afin d'éviter de créer deux fois la même conversation.
  String chatIdFor(String uidA, String uidB) {
    final sorted = [uidA, uidB]..sort();
    return sorted.join("_");
  }

  Stream<List<ChatConversation>> watchConversations(String uid) {
    return _chats
        .where("participantIds", arrayContains: uid)
        .orderBy("lastMessageAt", descending: true)
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              ChatConversation.fromMap(doc.id, doc.data()),
          ],
        );
  }

  Future<ChatConversation?> getChat(String chatId) async {
    final doc = await _chats.doc(chatId).get();
    if (!doc.exists) return null;
    return ChatConversation.fromMap(doc.id, doc.data()!);
  }

  Stream<List<ChatMessage>> watchMessages(String chatId) {
    return _chats
        .doc(chatId)
        .collection("messages")
        .orderBy("sentAt")
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              ChatMessage.fromMap(doc.id, doc.data()),
          ],
        );
  }

  /// Récupère la conversation existante entre `me` et `other`, ou la crée.
  Future<String> getOrCreateChat(UserProfile me, UserProfile other) async {
    final chatId = chatIdFor(me.uid, other.uid);
    final doc = _chats.doc(chatId);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({
        "participantIds": [me.uid, other.uid],
        "participants": {
          me.uid: {
            "email": me.email,
            "role": me.role.storageValue,
            if (me.displayName != null) "displayName": me.displayName,
          },
          other.uid: {
            "email": other.email,
            "role": other.role.storageValue,
            if (other.displayName != null) "displayName": other.displayName,
          },
        },
        "lastMessage": null,
        "lastMessageAt": FieldValue.serverTimestamp(),
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
    return chatId;
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final chatDoc = _chats.doc(chatId);
    await chatDoc.collection("messages").add({
      "senderId": senderId,
      "text": text,
      "sentAt": FieldValue.serverTimestamp(),
    });
    await chatDoc.update({
      "lastMessage": text,
      "lastMessageAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendImage({
    required String chatId,
    required String senderId,
    required Uint8List bytes,
  }) async {
    final ref = _storage.ref(
      "chats/$chatId/${DateTime.now().millisecondsSinceEpoch}.jpg",
    );
    await ref.putData(bytes, SettableMetadata(contentType: "image/jpeg"));
    final imageUrl = await ref.getDownloadURL();

    final chatDoc = _chats.doc(chatId);
    await chatDoc.collection("messages").add({
      "senderId": senderId,
      "text": "",
      "imageUrl": imageUrl,
      "sentAt": FieldValue.serverTimestamp(),
    });
    await chatDoc.update({
      "lastMessage": "📷 Photo",
      "lastMessageAt": FieldValue.serverTimestamp(),
    });
  }
}
