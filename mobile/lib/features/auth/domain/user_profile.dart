import "user_role.dart";

enum GuardianType {
  relative,
  organization;

  String get label => switch (this) {
    GuardianType.relative => "Un proche",
    GuardianType.organization => "Un organisme",
  };

  String get storageValue => name;

  static GuardianType? fromStorage(String? value) {
    if (value == null) return null;
    return GuardianType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => GuardianType.relative,
    );
  }
}

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
    this.guardianUid,
    this.guardianType,
    this.guardianName,
    this.guardianOrganization,
    this.guardianReference,
    this.onboardingCompleted = false,
    this.roleDetails = const {},
  });

  final String uid;
  final String email;
  final UserRole role;
  final String? displayName;
  final String? photoUrl;
  final NotificationPreferences preferences;
  final bool isAdmin;
  final String? guardianUid;
  final GuardianType? guardianType;
  final String? guardianName;
  final String? guardianOrganization;
  final String? guardianReference;
  final bool onboardingCompleted;
  final Map<String, dynamic> roleDetails;

  List<String> get serviceCategoryValues => _stringList("serviceCategories");

  List<String> get serviceSpecialties => _stringList("serviceSpecialties");

  List<String> get appointmentModeValues => _stringList("appointmentModes");

  List<String> _stringList(String key) {
    final value = roleDetails[key];
    if (value is! List) return const [];
    return [
      for (final item in value)
        if (item is String) item,
    ];
  }

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
      guardianUid: map["guardianUid"] as String?,
      guardianType: GuardianType.fromStorage(map["guardianType"] as String?),
      guardianName: map["guardianName"] as String?,
      guardianOrganization: map["guardianOrganization"] as String?,
      guardianReference: map["guardianReference"] as String?,
      onboardingCompleted: map["onboardingCompleted"] as bool? ?? false,
      roleDetails: Map<String, dynamic>.from(
        map["roleDetails"] as Map? ?? const {},
      ),
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
    if (guardianUid != null) "guardianUid": guardianUid,
    if (guardianType != null) "guardianType": guardianType!.storageValue,
    if (guardianName != null) "guardianName": guardianName,
    if (guardianOrganization != null)
      "guardianOrganization": guardianOrganization,
    if (guardianReference != null) "guardianReference": guardianReference,
    "onboardingCompleted": onboardingCompleted,
    "roleDetails": roleDetails,
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
      guardianUid: guardianUid,
      guardianType: guardianType,
      guardianName: guardianName,
      guardianOrganization: guardianOrganization,
      guardianReference: guardianReference,
      onboardingCompleted: onboardingCompleted,
      roleDetails: roleDetails,
    );
  }
}
