import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medipass/services/auth_service.dart';
import 'dart:developer' as developer;

class ShareCodeDialog extends StatefulWidget {
  const ShareCodeDialog({super.key});

  @override
  State<ShareCodeDialog> createState() => _ShareCodeDialogState();
}

class _ShareCodeDialogState extends State<ShareCodeDialog> {
  final AuthService _authService = AuthService();
  Timer? _countdownTimer;
  String? _shareCode;
  int _remainingSeconds = 300;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        if (mounted) setState(() => _shareCode = null);
      }
    });
  }

  Future<void> _generateCode() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final newCode = await _authService.generateShareCode();
      if (mounted) {
        if (newCode != null) {
          setState(() {
            _shareCode = newCode;
            _remainingSeconds = 300;
            _startTimer();
          });
        } else {
          setState(() => _errorMessage = "Le serveur a retourné une réponse nulle.");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  String _formattedTime() {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_isLoading) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Column(children: [CircularProgressIndicator(), SizedBox(height: 16), Text("Génération en cours...")]),
      );
    } else if (_shareCode == null) {
      content = Column(
        children: [
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(_errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            ),
          const Text("Générez un code à usage unique à donner à votre médecin.", textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Générer un code"),
            onPressed: _generateCode,
          )
        ],
      );
    } else {
      content = Column(
        children: [
          const Text("Ce code expirera dans :", textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(_formattedTime(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
          const SizedBox(height: 16),
          Text(
            _shareCode!,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4, fontFamily: 'monospace'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Code de Partage Sécurisé'),
      content: SizedBox(
        width: double.maxFinite,
        child: content,
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fermer'))],
    );
  }
}
