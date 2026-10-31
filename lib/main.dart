import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/fin_theme.dart';
import 'screens/home_page.dart';
import 'screens/security_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FinControlApp());
}

class FinControlApp extends StatelessWidget {
  const FinControlApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'FinControl',
        debugShowCheckedModeBanner: false,
        theme: finTheme(Brightness.light),
        darkTheme: finTheme(Brightness.dark),
        themeMode: ThemeMode.system,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const AppLockGate(child: FinHomePage()),
      );
}