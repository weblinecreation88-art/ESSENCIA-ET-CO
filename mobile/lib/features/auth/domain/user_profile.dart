import "user_role.dart";

class NotificationPreferences {
  const NotificationPreferences({
    this.notifyMessages = true,
    this.notifyBookings = true,
  });

  final bool notifyMessages;
  final bool notifyBookings;

  factory NotificationPreferences.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const NotificationPreferences();
    return NotificationPreferences(
      notifyMessages: map["notifyMessages"] as bool? ?? true,
      notifyBookings: map["notifyBookings"] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    "notifyMessages": notifyMessages,
    "notifyBookings": notifyBookings,
  };
}

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
    this.photoUrl,
    this.preferences = const NotificationPreferences(),
    this.isAdmin = false,
  });

  final String uid;
  final String email;
  final UserRole role;
  final String? displayName;
  final String? photoUrl;
  final NotificationPreferences preferences;
  final bool isAdmin;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      email: map["email"] as String? ?? "",
      role: UserRole.fromStorage(map["role"] as String),
      displayName: map["displayName"] as String?,
      photoUrl: map["photoUrl"] as String?,
      preferences: NotificationPreferences.fromMap(
        map["preferences"] as Map<String, dynamic>?,
      ),
      isAdmin: map["isAdmin"] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    "uid": uid,
    "email": email,
    "role": role.storageValue,
    if (displayName != null) "displayName": displayName,
    if (photoUrl != null) "photoUrl": photoUrl,
    "preferences": preferences.toMap(),
    if (isAdmin) "isAdmin": isAdmin,
  };

  UserProfile copyWith({String? displayName, String? photoUrl}) {
    return UserProfile(
      uid: uid,
      email: email,
      role: role,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      preferences: preferences,
      isAdmin: isAdmin,
    );
  }
}
