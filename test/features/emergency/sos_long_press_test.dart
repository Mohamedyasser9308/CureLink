import 'package:curelink/features/emergency/presentation/widgets/sos_long_press.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Pressing for less than 3 seconds does not activate SOS', (
    tester,
  ) async {
    int activationCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SosLongPress(
            onActivated: () => activationCount++,
            child: const SizedBox(width: 200, height: 200),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(SosLongPress)),
    );

    await tester.pump(const Duration(seconds: 2));
    await gesture.up();
    await tester.pump();

    expect(activationCount, 0);
  });

  testWidgets('Pressing for 3 seconds activates SOS once', (tester) async {
    int activationCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SosLongPress(
            onActivated: () => activationCount++,
            child: const SizedBox(width: 200, height: 200),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(SosLongPress)),
    );

    await tester.pump(const Duration(seconds: 3));

    expect(activationCount, 1);

    await tester.pump(const Duration(seconds: 2));

    expect(activationCount, 1);

    await gesture.up();
    await tester.pump();
  });

  testWidgets('Disabled SOS button does not activate', (tester) async {
    int activationCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SosLongPress(
            enabled: false,
            onActivated: () => activationCount++,
            child: const SizedBox(width: 200, height: 200),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(SosLongPress)),
    );

    await tester.pump(const Duration(seconds: 4));
    await gesture.up();

    expect(activationCount, 0);
  });
}
