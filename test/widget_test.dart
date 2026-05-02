import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turfspotx/screens/login_screen.dart';

void main() {
  testWidgets("LoginScreen loads without crashing", (tester) async {
    // Pump LoginScreen directly to bypass Firebase initialization in main.dart
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    // Ensure the new Fallback UI or Truecaller UI renders
    expect(find.text("Welcome to TurfSpotX"), findsOneWidget);
  });
}
