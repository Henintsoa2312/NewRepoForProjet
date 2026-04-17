import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer; // Import pour les logs

import '../models/message_model.dart';

// Écran de chat dédié à l'assistance médicale
class MedicalChatScreen extends StatefulWidget {
  const MedicalChatScreen({super.key});

  @override
  MedicalChatScreenState createState() => MedicalChatScreenState();
}

class MedicalChatScreenState extends State<MedicalChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Uuid _uuid = const Uuid();
  bool _isLoadingResponse = false;
  bool _isListening = false; // NOUVELLE VARIABLE D'ÉTAT

  final String _medicalApiUrl = 'http://10.0.2.2:5000/api/medical_chat';

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _addInitialBotMessage();
      }
    });
  }

  void _addInitialBotMessage() {
    const String welcomeText = "Bonjour. Je suis l'assistant médical virtuel de Medipass. Comment puis-je vous orienter ?\n\n**Attention :** Je ne remplace pas un avis médical professionnel. En cas d'urgence, contactez le 115.";
    final welcomeMessage = Message(
      id: _uuid.v4(),
      text: welcomeText,
      timestamp: DateTime.now(),
      sender: MessageSender.bot,
    );
    if (mounted) {
      setState(() {
        _messages.add(welcomeMessage);
      });
    }
  }

  void _addMessage(String text, MessageSender sender, {String? id}) {
    final messageId = id ?? _uuid.v4();
    final message = Message(
      id: messageId,
      text: text,
      timestamp: DateTime.now(),
      sender: sender,
    );
    if (mounted) {
      final existingIndex = _messages.indexWhere((m) => m.id == messageId && m.sender == MessageSender.bot);
      if (existingIndex != -1) {
        setState(() {
          _messages[existingIndex] = message;
        });
      } else {
        setState(() {
          _messages.add(message);
        });
      }
      _scrollToBottomAfterBuild();
    }
  }
  
  void _scrollToBottomAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // NOUVELLE MÉTHODE POUR GÉRER L'ENTRÉE VOCALE
  void _handleVoiceInput() {
    setState(() {
      _isListening = !_isListening;
    });

    // Pour l'instant, on affiche juste une notification.
    // Plus tard, ici on démarrera/arrêtera l'écoute.
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isListening ? 'Écoute en cours...' : 'Écoute terminée.'), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _submitPromptToMedicalAI(String prompt) async {
    if (prompt.trim().isEmpty || _isLoadingResponse) return;

    developer.log('Envoi du prompt à l\'IA médicale: "$prompt"', name: 'MedicalChat');

    _textController.clear();
    _addMessage(prompt, MessageSender.user);

    if (mounted) {
      setState(() { _isLoadingResponse = true; });
    }

    try {
      final requestBody = jsonEncode({
        'prompt': prompt,
        'history': _messages.map((m) => {'sender': m.sender.toString(), 'text': m.text}).toList(),
      });

      developer.log('Envoi de la requête à $_medicalApiUrl avec le corps: $requestBody', name: 'MedicalChat');

      final response = await http.post(
        Uri.parse(_medicalApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      ).timeout(const Duration(seconds: 45));

      developer.log('Réponse reçue avec le code de statut: ${response.statusCode}', name: 'MedicalChat');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final botResponse = jsonResponse['response'] ?? "Je n'ai pas de réponse à cela.";
        developer.log('Réponse décodée avec succès: "$botResponse"', name: 'MedicalChat');
        _addMessage(botResponse, MessageSender.bot);
      } else {
        developer.log(
          'Erreur du serveur. Statut: ${response.statusCode}, Corps: ${response.body}',
          name: 'MedicalChat',
          level: 900, // Niveau d'avertissement
        );
        _addMessage("Erreur de communication avec l'assistant médical (${response.statusCode}). Veuillez réessayer.", MessageSender.bot);
      }
    } catch (e, stackTrace) {
      developer.log(
        'Impossible de se connecter au serveur de l\'IA médicale.',
        name: 'MedicalChat',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // Niveau d'erreur
      );
      _addMessage("Impossible de joindre l'assistant médical. Vérifiez votre connexion et que le serveur est bien démarré. Erreur: $e", MessageSender.bot);
    } finally {
      if (mounted) {
        setState(() { _isLoadingResponse = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Assistant Médical"),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: theme.brightness == Brightness.dark ? 0 : 4,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: _messages.length,
                itemBuilder: (BuildContext context, int index) {
                  final message = _messages[index];
                  return _buildMessageItem(message);
                },
              ),
            ),
            if (_isLoadingResponse)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: LinearProgressIndicator(),
              ),
            _buildTextComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(Message message) {
    final theme = Theme.of(context);
    final isUser = message.sender == MessageSender.user;
    final bubbleColor = isUser ? theme.colorScheme.primary : theme.scaffoldBackgroundColor;
    final textColor = isUser ? Colors.white : theme.textTheme.bodyLarge?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(18.0),
              border: isUser ? null : Border.all(color: theme.dividerColor),
            ),
            child: Text(message.text, style: TextStyle(color: textColor, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // WIDGET MODIFIÉ POUR LA ZONE DE TEXTE FLOTTANTE AVEC LOGIQUE VOCALE
  Widget _buildTextComposer() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(25.0),
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: <Widget>[
              // BOUTON VOCAL AU DÉBUT
              IconButton(
                icon: Icon(_isListening ? Icons.mic_off_outlined : Icons.mic_none_outlined),
                color: _isListening ? Colors.red : theme.colorScheme.primary,
                onPressed: _handleVoiceInput,
              ),
              // LE CHAMP DE TEXTE OU L'INDICATEUR D'ÉCOUTE
              Flexible(
                child: _isListening
                    ? const Text(
                        "Écoute en cours...",
                        style: TextStyle(fontStyle: FontStyle.italic),
                      )
                    : TextField(
                        controller: _textController,
                        onSubmitted: _isLoadingResponse ? null : _submitPromptToMedicalAI,
                        decoration: const InputDecoration.collapsed(
                          hintText: "Décrivez vos symptômes...",
                        ),
                        textInputAction: TextInputAction.send,
                      ),
              ),
              // Le bouton envoyer est visible uniquement si on n'écoute pas
              if (!_isListening)
                IconButton(
                  icon: const Icon(Icons.send),
                  color: theme.colorScheme.primary,
                  onPressed: _isLoadingResponse
                      ? null
                      : () => _submitPromptToMedicalAI(_textController.text),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
