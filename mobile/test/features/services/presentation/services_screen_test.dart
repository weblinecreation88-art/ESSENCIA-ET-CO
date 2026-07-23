import "package:essencia_co/features/services/presentation/services_screen.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  testWidgets("les titres de catégories restent entiers sur un petit écran", (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: ServicesScreen()));

    const label = "Alimentation & restauration";
    await tester.scrollUntilVisible(find.text(label), 180);
    await tester.pumpAndSettle();

    final text = tester.widget<Text>(find.text(label));
    expect(text.maxLines, isNull);
    expect(text.overflow, isNot(TextOverflow.ellipsis));
    expect(tester.takeException(), isNull);
  });

  testWidgets("les catégories restent lisibles avec une police agrandie", (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.6)),
          child: child!,
        ),
        home: const ServicesScreen(),
      ),
    );

    const label = "Compagnie & accompagnement";
    await tester.scrollUntilVisible(find.text(label), 220);
    await tester.pumpAndSettle();

    final text = tester.widget<Text>(find.text(label));
    expect(text.maxLines, isNull);
    expect(text.overflow, isNot(TextOverflow.ellipsis));
    expect(tester.takeException(), isNull);
  });
}
