// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_project/main.dart';
import 'package:my_project/widgets/responsive_app_bar.dart';

void main() {
  testWidgets('CyberGuard app starts correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CybersecurityChatbot());
    await tester.pumpAndSettle();

    // Verify that the app starts without errors
    expect(find.byType(MaterialApp), findsWidgets);
  });

  testWidgets('ResponsiveAppBar builds without parent data errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(appBar: ResponsiveAppBar(title: 'CyberGuard')),
      ),
    );

    expect(find.text('CyberGuard'), findsOneWidget);
  });
}
