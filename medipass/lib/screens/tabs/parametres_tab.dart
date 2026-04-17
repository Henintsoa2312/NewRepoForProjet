import 'package:flutter/material.dart';
import 'package:medipass/services/auth_service.dart';
import 'package:medipass/screens/auth_screen.dart';
import 'package:medipass/services/locale_provider.dart';
import 'package:medipass/services/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/share_code_dialog.dart'; // Importer le nouveau widget

class ParametresTab extends StatefulWidget {
  const ParametresTab({super.key});

  @override
  State<ParametresTab> createState() => _ParametresTabState();
}

class _ParametresTabState extends State<ParametresTab> {
  bool _rememberSession = false;
  static const String _sessionKey = 'rememberSession';
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadSessionPreference();
  }

  Future<void> _loadSessionPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberSession = prefs.getBool(_sessionKey) ?? false;
    });
  }

  Future<void> _toggleSessionPreference(bool value) async {
    setState(() {
      _rememberSession = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionKey, value);
  }

  // MÉTHODE SIMPLIFIÉE QUI UTILISE LE NOUVEAU WIDGET
  Future<void> _showShareCodeDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const ShareCodeDialog();
      },
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Se déconnecter', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await _authService.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLanguageDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(title: const Text('Fonctionnalité désactivée'));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text("Paramètres de l'Application", textAlign: TextAlign.center, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Card(
          color: theme.cardColor,
          elevation: 2,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.screen_share_outlined, color: theme.colorScheme.secondary),
                title: const Text("Partager mes données"),
                subtitle: const Text("Générer un code pour votre médecin"),
                onTap: _showShareCodeDialog,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              SwitchListTile(
                title: const Text("Mode Sombre", style: TextStyle(fontWeight: FontWeight.w500)),
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(value),
                secondary: Icon(themeProvider.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded, color: theme.colorScheme.secondary),
                activeColor: theme.colorScheme.secondary,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              SwitchListTile(
                title: const Text("Mémoriser ma session", style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: const Text("Rester connecté au prochain démarrage"),
                value: _rememberSession,
                onChanged: _toggleSessionPreference,
                secondary: Icon(_rememberSession ? Icons.lock_open_rounded : Icons.lock_outline_rounded, color: theme.colorScheme.secondary),
                activeColor: theme.colorScheme.secondary,
              ),
            ],
          ),
        ),
        ListTile(
          leading: Icon(Icons.language_rounded, color: theme.colorScheme.secondary),
          title: const Text("Langue"),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          onTap: () => _showLanguageDialog(context),
        ),
        ListTile(
          leading: Icon(Icons.info_outline_rounded, color: theme.colorScheme.secondary),
          title: const Text("À propos de Medipass"),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          onTap: () {},
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.logout_rounded),
            label: const Text("Déconnexion"),
            onPressed: () => _showLogoutDialog(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
          ),
        ),
      ],
    );
  }
}
