import 'package:flutter_test/flutter_test.dart';
import 'package:turfzone/main.dart';

void main() {
  testWidgets("App loads without crashing", (tester) async {
    await tester.pumpWidget(const TurfZoneApp());

    // Check Role Selection Screen loads
    expect(find.text("Select Your Role"), findsOneWidget);
    expect(find.text("Continue as User/Admin"), findsOneWidget);
    expect(find.text("Super Admin Login"), findsOneWidget);
  });
}
