// lib/models/message_model.dart

// Énumération pour distinguer l'expéditeur du message
enum MessageSender { user, bot }

class Message {
  final String id; // Pour gérer l'expansion unique des messages
  final String text;
  final DateTime timestamp;
  final MessageSender sender;
  final bool isLongMessage; // Indicateur si le message est considéré comme long
  final bool isExpanded;    // État d'expansion du message

  Message({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.sender,
    this.isLongMessage = false,
    this.isExpanded = false,
  });

  // Méthode pour créer une copie avec des valeurs modifiées (utile pour l'expansion)
  Message copyWith({
    String? id,
    String? text,
    DateTime? timestamp,
    MessageSender? sender,
    bool? isLongMessage,
    bool? isExpanded,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      sender: sender ?? this.sender,
      isLongMessage: isLongMessage ?? this.isLongMessage,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

