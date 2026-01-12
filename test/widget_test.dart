// Widget tests for Find It app

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application/main.dart';

void main() {
  testWidgets('App loads and shows Find It branding', (
    WidgetTester tester,
  ) async {
    // Build the app and trigger a frame
    await tester.pumpWidget(const FindItApp());

    // Wait for SharedPreferences to load
    await tester.pumpAndSettle();

    // Verify the app title appears
    expect(find.text('Find It'), findsWidgets);
  });
}
