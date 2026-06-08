// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:aicar/main.dart';
import 'package:aicar/register_page.dart';

void main() {
  testWidgets('shows registration screen when Firebase is available', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp(home: RegisterPage()));

    expect(find.text('AI CARCARE'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Already have an account? Sign in'), findsOneWidget);
  });
}
