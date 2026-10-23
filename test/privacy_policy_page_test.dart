import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fincontrol/screens/privacy_policy_page.dart';

void main() {
  testWidgets('Politica de privacidade esta disponivel sem internet',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: PrivacyPolicyPage(),
    ));

    expect(find.text('Política de Privacidade'), findsOneWidget);
    expect(find.text('FinControl: Finanças Pessoais'), findsOneWidget);
    expect(find.text('FluxTools • com.app.fincontrol'), findsOneWidget);
    expect(find.text('1. Dados financeiros no aparelho'), findsOneWidget);
    expect(PrivacyPolicyPage.publicUrl,
        'https://thealbum0207-art.github.io/fincontrol/privacy/');
  });
}
