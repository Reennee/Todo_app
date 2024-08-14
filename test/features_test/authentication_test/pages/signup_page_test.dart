import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it_done/features/authentication/pages/signup_page.dart';
import 'package:get_it_done/providers/provider.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('SignUpForm Widget Test', () {
    testWidgets('TextFields Test', (WidgetTester tester) async {
      // Mock FirebaseAuth instance
      final mockFirebaseAuth = MockFirebaseAuth();

      final usernameField = find.byKey(const ValueKey("usernameField"));
      final emailField = find.byKey(const ValueKey("emailField"));
      final passwordField = find.byKey(const ValueKey("passwordField"));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<AuthStateProvider>.value(
              value: AuthStateProvider(firebaseAuth: mockFirebaseAuth),
              child: const SignUpForm(),
            ),
          ),
        ),
      );
      await tester.enterText(usernameField, "testuser");
      await tester.enterText(emailField, "test@example.com");
      await tester.enterText(passwordField, "testpassword");
      await tester.pump();

      expect(find.text("testuser"), findsOneWidget);
      expect(find.text("test@example.com"), findsOneWidget);
      expect(find.text("testpassword"), findsOneWidget);
    });
  });
}
