import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it_done/features/authentication/pages/signin_page.dart';
import 'package:get_it_done/providers/provider.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}


void main() {
  group('SignInForm Widget Test', () {
    testWidgets('TextFields Test', (WidgetTester tester) async {
      // Mock FirebaseAuth instance
      final mockFirebaseAuth = MockFirebaseAuth();

      final emailField = find.byKey(const ValueKey("emailField"));
      final passwordField = find.byKey(const ValueKey("passwordField"));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<AuthStateProvider>.value(
              value: AuthStateProvider(firebaseAuth: mockFirebaseAuth),
              child: const SignInForm(),
            ),
          ),
        ),
      );
      await tester.enterText(emailField, "user");
      await tester.enterText(passwordField, "password");
      await tester.pump();

      expect(find.text("user"), findsOneWidget);
      expect(find.text("password"), findsOneWidget);
    });
  });
}
