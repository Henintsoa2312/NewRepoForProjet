import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/message_model.dart';
import 'chatbot_settings_screen.dart';

enum _ChatMenuAction { regenerate, clearHistory, settings }

class MistralChatScreen extends StatefulWidget {
  const MistralChatScreen({Key? key}) : super(key: key);

  @override
  _MistralChatScreenState createState() => _MistralChatScreenState();
}

class _MistralChatScreenState extends State<MistralChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Uuid _uuid = const Uuid();
  bool _isLoadingResponse = false;
  String? _lastUserPromptForRegeneration;

  static const int _defaultLongMessageCharLimit = 250;
  late int _currentContextMessageLimit;
  late String _currentChatbotPersonality;

  final String _ollamaApiUrl = 'http://10.0.2.2:11434/api/generate';
  final String _ollamaModel = 'mistral:latest';

  @override
  void initState() {
    super.initState();
    _currentContextMessageLimit = 5;
    _currentChatbotPersonality = "Neutre et informatif";
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _addInitialBotMessage();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottomAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _messages.isNotEmpty) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addInitialBotMessage() {
    const String welcomeText = "Bonjour ! Je suis Mistral, servi par Ollama. Comment puis-je vous aider ?";
    final bool isLong = welcomeText.length > _defaultLongMessageCharLimit;
    final welcomeMessage = Message(
      id: _uuid.v4(),
      text: welcomeText,
      timestamp: DateTime.now(),
      sender: MessageSender.bot,
      isLongMessage: isLong,
    );
    if (mounted) {
      setState(() {
        _messages.add(welcomeMessage);
      });
      _scrollToBottomAfterBuild();
    }
  }

  void _addMessage(String text, MessageSender sender, {String? id, bool isError = false}) {
    final bool isLong = text.length > _defaultLongMessageCharLimit;
    final messageId = id ?? _uuid.v4();
    if (sender == MessageSender.user && !isError) {
      _lastUserPromptForRegeneration = text;
    }
    final message = Message(
      id: messageId,
      text: text,
      timestamp: DateTime.now(),
      sender: sender,
      isLongMessage: isLong,
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

  String _buildContextualPrompt(String currentPrompt) {
    String contextualPrompt = "";
    if (_currentChatbotPersonality != "Neutre et informatif" && _currentChatbotPersonality.isNotEmpty) {
      contextualPrompt += "System: Adopte la personnalité suivante pour tes réponses : '$_currentChatbotPersonality'.\n";
    }

    if (_currentContextMessageLimit > 0 && _messages.isNotEmpty) {
      int startIndex = _messages.length > _currentContextMessageLimit ? _messages.length - _currentContextMessageLimit : 0;
      for (int i = startIndex; i < _messages.length; i++) {
        final msg = _messages[i];
        if (msg.sender == MessageSender.user) {
          contextualPrompt += "User: ${msg.text}\n";
        } else {
          if (!msg.text.toLowerCase().contains("erreur") && !msg.text.toLowerCase().contains("désolé")) {
            contextualPrompt += "Assistant: ${msg.text}\n";
          }
        }
      }
    }
    contextualPrompt += "User: $currentPrompt\nAssistant: ";
    return contextualPrompt;
  }

  Future<void> _submitPromptToOllama(String prompt, {bool isRegeneration = false}) async {
    if (prompt.trim().isEmpty || _isLoadingResponse) return;

    if (!isRegeneration) {
      _textController.clear();
      _addMessage(prompt, MessageSender.user);
    }

    if (mounted) {
      setState(() { _isLoadingResponse = true; });
    }

    final String botResponseId = _uuid.v4();
    String accumulatedResponse = "";
    final String contextualPromptVal = _buildContextualPrompt(prompt);

    try {
      final requestBody = jsonEncode({
        'model': _ollamaModel,
        'prompt': contextualPromptVal,
        'stream': true,
      });
      final request = http.Request('POST', Uri.parse(_ollamaApiUrl))
        ..headers['Content-Type'] = 'application/json'
        ..body = requestBody;

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        streamedResponse.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(
              (chunk) {
            if (mounted) {
              try {
                final jsonResponse = jsonDecode(chunk);
                if (jsonResponse['response'] != null) {
                  accumulatedResponse += jsonResponse['response'] as String;
                  _addMessage(accumulatedResponse.trim(), MessageSender.bot, id: botResponseId);
                }
                if (jsonResponse['done'] == true) {
                  if (accumulatedResponse.trim().isEmpty && jsonResponse['response'] == null) {
                    _addMessage("Je n'ai pas de réponse spécifique à cela.", MessageSender.bot, id: botResponseId);
                  }
                  if (jsonResponse.containsKey('error')) {
                    _addMessage("Erreur du modèle Ollama : ${jsonResponse['error']}", MessageSender.bot, id: botResponseId, isError: true);
                  }
                  setState(() { _isLoadingResponse = false; });
                }
              } catch (e) {
                print("Erreur de parsing JSON du chunk: $e - Chunk: $chunk");
              }
            }
          },
          onDone: () {
            if (mounted && _isLoadingResponse) {
              if (accumulatedResponse.trim().isEmpty) {
                _addMessage("Aucune réponse reçue ou réponse vide.", MessageSender.bot, id: botResponseId, isError: true);
              }
              setState(() { _isLoadingResponse = false; });
            }
          },
          onError: (error, stackTrace) {
            print("Erreur de streaming de l'API Ollama: $error\n$stackTrace");
            if (mounted) {
              _addMessage("Erreur de streaming: $error", MessageSender.bot, id: botResponseId, isError: true);
              setState(() { _isLoadingResponse = false; });
            }
          },
          cancelOnError: true,
        );
      } else {
        final errorBody = await streamedResponse.stream.bytesToString();
        String displayError = "Erreur de connexion au service Mistral (${streamedResponse.statusCode}).";
        try {
          final decodedError = jsonDecode(errorBody);
          if (decodedError['error'] != null) {
            displayError += "\nDétail: ${decodedError['error']}";
            if (decodedError['error'].toString().toLowerCase().contains("model not found")) {
              displayError = "Le modèle '$_ollamaModel' n'a pas été trouvé sur le serveur Ollama.";
            }
          }
        } catch (_) { /* Ignorer l'erreur de parsing */ }
        _addMessage(displayError, MessageSender.bot, isError: true);
        if (mounted) { setState(() { _isLoadingResponse = false; }); }
      }
    } catch (e, stackTrace) {
      print("Erreur lors de l'appel à l'API Ollama: $e\n$stackTrace");
      if (mounted) {
        String networkErrorMsg = "Impossible de se connecter au service Mistral. Vérifiez votre connexion et la configuration d'Ollama.";
        if (e.toString().contains("SocketException") || e.toString().contains("HttpException")) {
          networkErrorMsg += "\nAssurez-vous que l'URL '$_ollamaApiUrl' est correcte et accessible.";
        }
        _addMessage("$networkErrorMsg ($e)", MessageSender.bot, isError: true);
        setState(() { _isLoadingResponse = false; });
      }
    }
  }

  void _regenerateLastBotResponse() {
    if (_isLoadingResponse) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez attendre la réponse actuelle.")));
      return;
    }
    if (_lastUserPromptForRegeneration != null && _lastUserPromptForRegeneration!.isNotEmpty) {
      _submitPromptToOllama(_lastUserPromptForRegeneration!, isRegeneration: true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Aucun message à régénérer.")));
    }
  }

  void _clearChatHistory() {
    if (mounted) {
      setState(() {
        _messages.clear();
        _lastUserPromptForRegeneration = null;
      });
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          _addInitialBotMessage();
        }
      });
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Message copié dans le presse-papiers !")));
    });
  }

  void _showActionsMenu(BuildContext context, Message message) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.copy_rounded, color: theme.iconTheme.color),
                title: const Text('Copier le texte'),
                onTap: () {
                  Navigator.of(context).pop();
                  _copyToClipboard(message.text);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleExpandMessage(String messageId) {
    if (!mounted) return;
    setState(() {
      final index = _messages.indexWhere((msg) => msg.id == messageId);
      if (index != -1) {
        final currentMessage = _messages[index];
        _messages[index] = currentMessage.copyWith(isExpanded: !currentMessage.isExpanded);
      }
    });
  }

  Widget _buildMessageItem(Message message, Message? previousMessage) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final bool isUser = message.sender == MessageSender.user;
    
    final bubbleColor = isUser 
      ? theme.colorScheme.primary 
      : (isDarkMode ? Colors.grey.shade800 : theme.colorScheme.secondaryContainer);
      
    final textColorOnBubble = isUser 
      ? theme.colorScheme.onPrimary 
      : theme.colorScheme.onSecondaryContainer;

    final timestampColor = theme.textTheme.bodySmall?.color?.withOpacity(0.6);

    final bool showTimestampHeader = previousMessage == null || message.timestamp.difference(previousMessage.timestamp).inMinutes > 5;
    String displayText = message.text;
    bool actualIsLongMessage = message.text.length > _defaultLongMessageCharLimit;

    if (actualIsLongMessage && !message.isExpanded) {
      displayText = '${message.text.substring(0, _defaultLongMessageCharLimit)}...';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTimestampHeader)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Center(
              child: Text(
                DateFormat('EEE, HH:mm', 'fr_FR').format(message.timestamp),
                style: TextStyle(color: timestampColor, fontSize: 12),
              ),
            ),
          ),
        InkWell(
          onLongPress: message.sender == MessageSender.bot ? () => _showActionsMenu(context, message) : null,
          child: Padding(
            padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: isUser ? 60.0 : 15.0, right: isUser ? 15.0 : 60.0),
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18.0),
                      topRight: const Radius.circular(18.0),
                      bottomLeft: isUser ? const Radius.circular(18.0) : const Radius.circular(4.0),
                      bottomRight: isUser ? const Radius.circular(4.0) : const Radius.circular(18.0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(displayText, style: TextStyle(color: textColorOnBubble, fontSize: 16), softWrap: true),
                      if (actualIsLongMessage)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: InkWell(
                            onTap: () => _toggleExpandMessage(message.id),
                            child: Text(
                              message.isExpanded ? "Voir moins" : "Voir plus",
                              style: TextStyle(color: textColorOnBubble.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: Text(DateFormat('HH:mm', 'fr_FR').format(message.timestamp), style: TextStyle(fontSize: 10, color: timestampColor)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToSettings() async {
    final result = await Navigator.push<ChatbotSettingsResult>(
      context,
      MaterialPageRoute(
        builder: (context) => ChatbotSettingsScreen(
          initialContextMessageLimit: _currentContextMessageLimit,
          initialChatbotPersonality: _currentChatbotPersonality,
        ),
      ),
    );

    if (result != null && mounted) {
      bool settingsChanged = false;
      String changesSummary = "Préférences mises à jour :";
      if (_currentContextMessageLimit != result.contextMessageLimit) {
        setState(() { _currentContextMessageLimit = result.contextMessageLimit; });
        changesSummary += "\n- Limite de contexte : ${result.contextMessageLimit}";
        settingsChanged = true;
      }
      if (_currentChatbotPersonality != result.chatbotPersonality) {
        setState(() { _currentChatbotPersonality = result.chatbotPersonality; });
        changesSummary += "\n- Personnalité : ${result.chatbotPersonality}";
        settingsChanged = true;
      }
      if (settingsChanged) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(changesSummary), duration: const Duration(seconds: 3)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Mistral (${_ollamaModel.split(':')[0]})"),
        elevation: theme.brightness == Brightness.dark ? 0 : 4,
        actions: [
          PopupMenuButton<_ChatMenuAction>(
            icon: const Icon(Icons.more_vert_rounded),
            tooltip: "Options du Chat",
            onSelected: (_ChatMenuAction action) {
              switch (action) {
                case _ChatMenuAction.regenerate:
                  _regenerateLastBotResponse();
                  break;
                case _ChatMenuAction.clearHistory:
                  _clearChatHistory();
                  break;
                case _ChatMenuAction.settings:
                  _navigateToSettings();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<_ChatMenuAction>>[
              const PopupMenuItem<_ChatMenuAction>(
                value: _ChatMenuAction.regenerate,
                child: ListTile(leading: Icon(Icons.refresh_rounded), title: Text('Régénérer')),
              ),
              const PopupMenuItem<_ChatMenuAction>(
                value: _ChatMenuAction.clearHistory,
                child: ListTile(leading: Icon(Icons.delete_sweep_rounded), title: Text('Effacer l\'historique')),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<_ChatMenuAction>(
                value: _ChatMenuAction.settings,
                child: ListTile(leading: Icon(Icons.settings_suggest_rounded), title: Text('Préférences')),
              ),
            ],
          ),
        ],
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
                  final previousMessage = index > 0 ? _messages[index - 1] : null;
                  return _buildMessageItem(message, previousMessage);
                },
              ),
            ),
            if (_isLoadingResponse)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 15),
                    const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.0)),
                    const SizedBox(width: 10),
                    Text("Mistral écrit...", style: TextStyle(color: theme.textTheme.bodySmall?.color)),
                  ],
                ),
              ),
            Divider(height: 1.0, color: theme.dividerColor),
            Container(
              decoration: BoxDecoration(color: theme.cardColor),
              child: _buildTextComposer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextComposer() {
    final theme = Theme.of(context);

    return IconTheme(
      data: IconThemeData(color: theme.colorScheme.primary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _isLoadingResponse ? null : (text) => _submitPromptToOllama(text),
                decoration: InputDecoration.collapsed(hintText: "Envoyer un message à Mistral..."),
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _isLoadingResponse ? null : () => _submitPromptToOllama(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
