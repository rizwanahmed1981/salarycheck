// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

void main() {
  testWidgets('SalaryCheckApp UI smoke test', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(SalaryCheckApp());

    // Verify the main title is present
    expect(find.text('SalaryCheck'), findsOneWidget);

    // Verify the subtitle is present
    expect(find.textContaining('See what people'), findsOneWidget);

    // Verify the search field is present
    expect(find.byType(TextField), findsOneWidget);

    // Verify the button is present
    expect(find.text('Check Salary'), findsOneWidget);
  });
}
