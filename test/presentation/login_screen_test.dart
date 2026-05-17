import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ninaivu/presentation/modules/common/auth/login_screen.dart';

void main() {
  testWidgets('login screen renders primary actions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          onGoogleSignIn: () async {},
          onSendOtp: (_) async {},
        ),
      ),
    );

    expect(find.text('Welcome to Ninaivu'), findsOneWidget);
    expect(find.text('Continue with Mobile Number'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
