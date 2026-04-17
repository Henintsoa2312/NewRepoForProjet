import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:medipass/screens/splash_screen.dart';
import 'package:medipass/services/locale_provider.dart';
import 'package:medipass/services/theme_provider.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // COMMENTÉ

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  final themeProvider = await ThemeProvider.create();
  final localeProvider = await LocaleProvider.create();
  runApp(MyApp(themeProvider: themeProvider, localeProvider: localeProvider));
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  final LocaleProvider localeProvider;

  const MyApp({Key? key, required this.themeProvider, required this.localeProvider}) : super(key: key);

  static const Color primaryColor = Color(0xFF00897B);
  static const Color secondaryColorLight = Color(0xFF00796B);
  static const Color secondaryColorDark = Color(0xFF4DB6AC);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'Medipass App',
            debugShowCheckedModeBanner: false,

            // Thème
            theme: ThemeData.light().copyWith(
              primaryColor: primaryColor,
              colorScheme: const ColorScheme.light().copyWith(primary: primaryColor, secondary: secondaryColorLight),
              scaffoldBackgroundColor: Colors.grey[50],
              cardColor: Colors.white,
            ),
            darkTheme: ThemeData.dark().copyWith(
              primaryColor: primaryColor,
              colorScheme: const ColorScheme.dark().copyWith(primary: primaryColor, secondary: secondaryColorDark),
              scaffoldBackgroundColor: Colors.grey[900],
              cardColor: Colors.grey[850],
            ),
            themeMode: themeProvider.themeMode,

            // Langue
            locale: localeProvider.locale,
            supportedLocales: const [ Locale('fr', 'FR'), Locale('en', 'US') ], // Utilise une liste simple pour le moment
            localizationsDelegates: const [
              // AppLocalizations.delegate, // COMMENTÉ
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
