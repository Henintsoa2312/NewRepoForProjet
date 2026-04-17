import 'package:flutter/material.dart';
import 'package:medipass/widgets/login_form.dart';
import 'package:medipass/widgets/register_form.dart';
import 'package:provider/provider.dart';
import 'package:medipass/services/theme_provider.dart';

enum AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMode _authMode = AuthMode.login;

  void _switchAuthMode() {
    setState(() {
      _authMode = _authMode == AuthMode.login ? AuthMode.register : AuthMode.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    // On utilise le themeProvider pour avoir un rendu cohérent dès le début
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(
                Icons.medical_services_outlined,
                size: 60,
                color: themeProvider.isDarkMode ? Colors.teal[200] : Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: _authMode == AuthMode.login
                    ? LoginForm(
                        key: const ValueKey('LoginForm'),
                        onSwitchToRegister: _switchAuthMode,
                      )
                    : RegisterForm(
                        key: const ValueKey('RegisterForm'),
                        onLoginInstead: _switchAuthMode,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
