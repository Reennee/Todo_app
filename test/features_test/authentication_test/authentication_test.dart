import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it_done/features/authentication/authentication.dart';
import 'package:get_it_done/providers/provider.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

// Mock AuthStateProvider class using Mockito
class MockAuthStateProvider extends Mock implements AuthStateProvider {
   @override
  bool get signedState => false;
}

void main() {
  group('Authentication Widget Test', () {
    testWidgets('Displays text and buttons properly', (WidgetTester tester) async {
      // Mock AuthStateProvider instance
      final mockAuthStateProvider = MockAuthStateProvider();


      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthStateProvider>.value(
            value: mockAuthStateProvider,
            child: const Authentication(),
          ),
        ),
      );
      
      await tester.pump();
      expect(find.byKey(const Key('alreadyAMemberText')), findsOneWidget);
      expect(find.byKey(const Key('logInButton')), findsOneWidget);

    });
  });
}
