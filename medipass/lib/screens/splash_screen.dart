import 'package:flutter/material.dart';
import 'package:medipass/screens/auth_screen.dart';
import 'package:medipass/services/auth_service.dart';
import 'dart:developer' as developer;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _forceCleanAndNavigate();
    });
  }

  Future<void> _forceCleanAndNavigate() async {
    // ÉTAPE 1: Tenter de nettoyer la session, mais continuer même en cas d'erreur.
    try {
      developer.log("Nettoyage forcé (mode ultra-robuste)...", name: 'SplashScreen');
      await _authService.logout();
      developer.log("Nettoyage terminé.", name: 'SplashScreen');
    } catch (e, stackTrace) {
      developer.log(
        "Erreur pendant le nettoyage forcé, mais on continue quand même.",
        name: 'SplashScreen',
        error: e,
        stackTrace: stackTrace,
      );
    }

    // Petite attente pour l'effet visuel
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // ÉTAPE 2: Naviguer vers l'écran de connexion, quoi qu'il arrive.
    try {
      developer.log("Tentative de navigation vers AuthScreen.", name: 'SplashScreen');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    } catch (e) {
      developer.log("ERREUR CRITIQUE: La navigation vers AuthScreen a échoué: $e", name: 'SplashScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Remplacer Lottie par un widget simple et GARANTI de fonctionner
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Initialisation...'),
          ],
        ),
      ),
    );
  }
}
