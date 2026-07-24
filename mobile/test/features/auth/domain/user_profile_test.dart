import "package:flutter_test/flutter_test.dart";

import "package:essencia_co/features/auth/domain/user_profile.dart";
import "package:essencia_co/features/auth/domain/user_role.dart";

void main() {
  group("UserProfile onboarding", () {
    test("an existing profile must complete the new questionnaire", () {
      final profile = UserProfile.fromMap("user-1", {
        "email": "marie@example.com",
        "role": UserRole.resident.storageValue,
      });

      expect(profile.onboardingCompleted, isFalse);
      expect(profile.roleDetails, isEmpty);
    });

    test("reads provider service answers", () {
      final profile = UserProfile.fromMap("provider-1", {
        "email": "pro@example.com",
        "role": UserRole.provider.storageValue,
        "onboardingCompleted": true,
        "roleDetails": {
          "serviceCategories": ["santeAccompagnement"],
          "serviceSpecialties": ["Infirmiers", "Kinésithérapeutes"],
          "appointmentModes": ["video", "inPerson"],
        },
      });

      expect(profile.onboardingCompleted, isTrue);
      expect(profile.serviceCategoryValues, ["santeAccompagnement"]);
      expect(profile.serviceSpecialties, ["Infirmiers", "Kinésithérapeutes"]);
      expect(profile.appointmentModeValues, ["video", "inPerson"]);
    });

    test("ignores malformed list values safely", () {
      final profile = UserProfile.fromMap("provider-2", {
        "email": "pro2@example.com",
        "role": UserRole.provider.storageValue,
        "roleDetails": {
          "serviceCategories": "not-a-list",
          "serviceSpecialties": ["Infirmiers", 12, null],
        },
      });

      expect(profile.serviceCategoryValues, isEmpty);
      expect(profile.serviceSpecialties, ["Infirmiers"]);
      expect(profile.appointmentModeValues, isEmpty);
    });
  });
}
