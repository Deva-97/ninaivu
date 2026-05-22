import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/localization/app_translations.dart';
import 'package:ninaivu/presentation/modules/common/auth/login_screen.dart';

void main() {
  testWidgets('login screen renders primary actions', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        fallbackLocale: const Locale('en', 'US'),
        home: LoginScreen(onGoogleSignIn: () async {}, onSendOtp: (_) async {}),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Welcome to Ninaivu'), findsOneWidget);
    expect(find.text('Continue with Mobile Number'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Continue with Google'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
