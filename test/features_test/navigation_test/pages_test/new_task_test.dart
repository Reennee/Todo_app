import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get_it_done/features/navigation/pages/new_task.dart';

void main() {
  testWidgets('New Task Page has a title and a body', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: NewTask()));

    expect(find.text('New Task'), findsOneWidget);
    expect(find.text('Your Tasks go in here!'), findsOneWidget);
  });
}