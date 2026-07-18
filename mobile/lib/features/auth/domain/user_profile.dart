import "user_role.dart";

class UserProfile {
  const UserProfile({required this.uid, required this.email, required this.role});

  final String uid;
  final String email;
  final UserRole role;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      email: map["email"] as String? ?? "",
      role: UserRole.fromStorage(map["role"] as String),
    );
  }

  Map<String, dynamic> toMap() => {
    "uid": uid,
    "email": email,
    "role": role.storageValue,
  };
}
