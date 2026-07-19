import "../../auth/domain/user_role.dart";

/// Copie dénormalisée d'un participant, stockée dans le document `chats/{id}`
/// pour afficher la liste des conversations sans requête supplémentaire.
class ChatParticipant {
  const ChatParticipant({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
  });

  final String uid;
  final String email;
  final UserRole role;
  final String? displayName;

  String get name =>
      (displayName?.isNotEmpty ?? false) ? displayName! : email;

  factory ChatParticipant.fromMap(String uid, Map<String, dynamic> map) {
    return ChatParticipant(
      uid: uid,
      email: map["email"] as String? ?? "",
      role: UserRole.fromStorage(map["role"] as String),
      displayName: map["displayName"] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    "email": email,
    "role": role.storageValue,
    if (displayName != null) "displayName": displayName,
  };
}
