import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../models/message_model.dart';

class DoctorChatScreen extends StatefulWidget {
  const DoctorChatScreen({super.key});

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  late IO.Socket _socket;

  // MODIFIÉ: Utilisation des IDs de vos logs de test
  final String _patientId = "2";
  final String _doctorId = "4";
  late final String _roomName;

  @override
  void initState() {
    super.initState();
    _roomName = "chat_patient${_patientId}_doctor${_doctorId}";
    _initSocket();
  }

  void _initSocket() {
    _socket = IO.io('http://10.0.2.2:3001', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.connect();

    _socket.onConnect((_) {
      developer.log('Connecté au serveur WebSocket!', name: 'SocketIO');
      _socket.emit('join_room', _roomName);
      developer.log('Rejoint la salle: $_roomName', name: 'SocketIO'); // Log pour confirmer
    });

    _socket.on('receive_message', (data) {
      developer.log('Message reçu: $data', name: 'SocketIO');
      if (data['content'] != null) {
        final message = Message(
          id: DateTime.now().toIso8601String(),
          text: data['content'],
          timestamp: DateTime.now(),
          sender: (data['isDoctor'] == true) ? MessageSender.bot : MessageSender.user,
        );
        if (mounted) {
          setState(() {
            _messages.insert(0, message);
          });
        }
      }
    });

    _socket.onDisconnect((_) => developer.log('Déconnecté', name: 'SocketIO'));
    _socket.onError((err) => developer.log('Erreur Socket: $err', name: 'SocketIO'));
  }

  @override
  void dispose() {
    _textController.dispose();
    _socket.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final message = Message(
      id: DateTime.now().toIso8601String(),
      text: text,
      timestamp: DateTime.now(),
      sender: MessageSender.user,
    );
    if (mounted) {
      setState(() {
        _messages.insert(0, message);
      });
    }

    _socket.emit('send_message', {
      'room': _roomName,
      'content': text,
      'senderId': _patientId, 
      'isDoctor': false
    });

    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messagerie Docteur"),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Icon(
                _socket.connected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                color: _socket.connected ? Colors.white : Colors.white54,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.sender == MessageSender.user;
                return _buildMessageBubble(message, isUser, theme);
              },
            ),
          ),
          _buildTextComposer(theme),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isUser, ThemeData theme) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: isUser ? theme.primaryColor : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: isUser ? Colors.white : theme.textTheme.bodyLarge?.color),
        ),
      ),
    );
  }

  Widget _buildTextComposer(ThemeData theme) {
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
              Flexible(
                child: TextField(
                  controller: _textController,
                  onSubmitted: _sendMessage,
                  decoration: const InputDecoration.collapsed(
                    hintText: "Envoyer un message au médecin...",
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                color: theme.colorScheme.primary,
                onPressed: () => _sendMessage(_textController.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
