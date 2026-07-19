import "package:flutter/material.dart";

import "../../../core/theme/app_colors.dart";

/// Rôles auto-attribuables à l'inscription. Le rôle "admin" n'est pas
/// proposé ici : il est réservé à une attribution manuelle côté back-office.
enum UserRole {
  resident,
  family,
  professional,
  provider;

  String get label => switch (this) {
    UserRole.resident => "Résident",
    UserRole.family => "Famille",
    UserRole.professional => "Professionnel",
    UserRole.provider => "Prestataire",
  };

  Color get color => switch (this) {
    UserRole.resident => AppColors.roleResident,
    UserRole.family => AppColors.roleFamily,
    UserRole.professional => AppColors.roleProfessional,
    UserRole.provider => AppColors.roleProvider,
  };

  IconData get icon => switch (this) {
    UserRole.resident => Icons.favorite_rounded,
    UserRole.family => Icons.people_alt_rounded,
    UserRole.professional => Icons.medical_services_rounded,
    UserRole.provider => Icons.local_shipping_rounded,
  };

  /// Avatar par défaut affiché tant que l'utilisateur n'a pas mis sa propre photo.
  String get defaultAvatarAsset => switch (this) {
    UserRole.resident => "assets/images/avatars/resident.png",
    UserRole.family => "assets/images/avatars/family.png",
    UserRole.professional => "assets/images/avatars/professional.png",
    UserRole.provider => "assets/images/avatars/provider.png",
  };

  /// Valeur stockée dans Firestore (`users/{uid}.role`).
  String get storageValue => name;

  static UserRole fromStorage(String value) =>
      UserRole.values.firstWhere((role) => role.name == value);
}
