import "user_role.dart";

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
    this.photoUrl,
  });

  final String uid;
  final String email;
  final UserRole role;
  final String? displayName;
  final String? photoUrl;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      email: map["email"] as String? ?? "",
      role: UserRole.fromStorage(map["role"] as String),
      displayName: map["displayName"] as String?,
      photoUrl: map["photoUrl"] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    "uid": uid,
    "email": email,
    "role": role.storageValue,
    if (displayName != null) "displayName": displayName,
    if (photoUrl != null) "photoUrl": photoUrl,
  };

  UserProfile copyWith({String? displayName, String? photoUrl}) {
    return UserProfile(
      uid: uid,
      email: email,
      role: role,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
