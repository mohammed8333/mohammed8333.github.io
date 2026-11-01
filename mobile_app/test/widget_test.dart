import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pizza_awlad_alsheikh/main.dart';

void main() {
  testWidgets('Pizza Awlad Alsheikh App builds and initializes cleanly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const PizzaAwladAlsheikhApp());
    expect(find.byType(PizzaAwladAlsheikhApp), findsOneWidget);

    // Dispose widget tree to trigger timer cleanup
    await tester.pumpWidget(const SizedBox());
  });
}
