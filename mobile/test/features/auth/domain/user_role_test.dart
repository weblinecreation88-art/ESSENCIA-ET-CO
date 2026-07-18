import 'package:flutter_test/flutter_test.dart';

import 'package:essencia_co/features/auth/domain/user_role.dart';

void main() {
  test('storageValue et fromStorage font un aller-retour cohérent', () {
    for (final role in UserRole.values) {
      final stored = role.storageValue;
      expect(UserRole.fromStorage(stored), role);
    }
  });

  test('chaque rôle a un libellé français distinct', () {
    final labels = UserRole.values.map((role) => role.label).toSet();
    expect(labels.length, UserRole.values.length);
  });
}
