import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:essencia_co/core/widgets/placeholder_screen.dart';

void main() {
  testWidgets('PlaceholderScreen affiche son titre', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: PlaceholderScreen(title: 'Agenda')),
    );

    expect(find.text('Agenda'), findsWidgets);
    expect(find.text('Écran à venir'), findsOneWidget);
  });
}
