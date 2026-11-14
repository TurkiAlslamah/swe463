import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:laqait/main.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> startApp(WidgetTester tester) async {
    await tester.pumpWidget(const LaqaitApp());
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('App starts on the Sign In screen', (tester) async {
    await startApp(tester);

    expect(find.text('Laqait'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('Sign In rejects empty and non-KFUPM input', (tester) async {
    await startApp(tester);

    await tester.tap(find.text('Sign in'));
    await tester.pump();
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'omar@gmail.com');
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    expect(find.text('Use your @kfupm.edu.sa email'), findsOneWidget);
  });

  testWidgets('Valid sign in opens Home with the reports', (tester) async {
    await startApp(tester);

    await tester.enterText(
        find.byType(TextFormField).at(0), 'omar@kfupm.edu.sa');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret1');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Found'), findsWidgets);
    expect(find.text('Black AirPods case'), findsOneWidget);
  });
}
