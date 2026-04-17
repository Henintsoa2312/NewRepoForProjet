import 'package:flutter_test/flutter_test.dart';
import 'package:medipass/main.dart';
import 'package:medipass/screens/splash_screen.dart';
import 'package:medipass/services/locale_provider.dart';
import 'package:medipass/services/theme_provider.dart';

void main() {
  testWidgets('App starts and shows SplashScreen', (WidgetTester tester) async {
    // Créez les instances des providers nécessaires pour le test.
    final themeProvider = await ThemeProvider.create();
    final localeProvider = await LocaleProvider.create();

    // Construisez l'application avec les deux providers.
    await tester.pumpWidget(MyApp(
      themeProvider: themeProvider,
      localeProvider: localeProvider,
    ));

    // Vérifiez que le SplashScreen est bien affiché au démarrage.
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
