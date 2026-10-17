import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:laqait/main.dart';

void main() {
  testWidgets('App starts on the Sign In screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const LaqaitApp());
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Laqait'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });
}
