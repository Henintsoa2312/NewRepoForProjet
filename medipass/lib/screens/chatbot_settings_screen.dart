// lib/screens/chatbot_settings_screen.dart
import 'package:flutter/material.dart';

// Classe pour encapsuler les préférences retournées (assurez-vous qu'elle est définie)
class ChatbotSettingsResult {
  final int contextMessageLimit;
  final String chatbotPersonality;

  ChatbotSettingsResult({
    required this.contextMessageLimit,
    required this.chatbotPersonality,
  });
}

class ChatbotSettingsScreen extends StatefulWidget {
  final int initialContextMessageLimit;
  final String initialChatbotPersonality;

  const ChatbotSettingsScreen({
    Key? key,
    required this.initialContextMessageLimit,
    required this.initialChatbotPersonality,
  }) : super(key: key);

  @override
  _ChatbotSettingsScreenState createState() => _ChatbotSettingsScreenState();
}

class _ChatbotSettingsScreenState extends State<ChatbotSettingsScreen> {
  late int _currentContextMessageLimit;
  late String _currentChatbotPersonality;

  late TextEditingController _contextLimitController;
  // Options de personnalité (vous pouvez les étendre)
  final List<String> _personalityOptions = [
  "Neutre et informatif",
  "Amical et conversationnel",
  "Concis et direct",
    "Créatif et imaginatif",
    "Expert technique",
  ];

  @override
  void initState() {
    super.initState();
    _currentContextMessageLimit = widget.initialContextMessageLimit;
    _currentChatbotPersonality = widget.initialChatbotPersonality;
    _contextLimitController = TextEditingController(text: _currentContextMessageLimit.toString());

    // S'assurer que la personnalité initiale est dans la liste, sinon prendre la première
    if (!_personalityOptions.contains(_currentChatbotPersonality)) {
      _currentChatbotPersonality = _personalityOptions.isNotEmpty ? _personalityOptions.first : "Neutre et informatif";
    }
  }

  @override
  void dispose() {
    _contextLimitController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final newLimit = int.tryParse(_contextLimitController.text);
    bool limitIsValid = false;

    if (newLimit != null && newLimit >= 0 && newLimit <= 20) { // Limite raisonnable
      limitIsValid = true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Limite de contexte invalide. Veuillez entrer un nombre entre 0 et 20.')),
      );
      return; // Ne pas sauvegarder si la limite est invalide
    }

    // Si toutes les validations passent (ici, seulement la limite de contexte pour l'instant)
    if (limitIsValid) {
      Navigator.pop(
        context,
        ChatbotSettingsResult(
          contextMessageLimit: newLimit, // Utiliser la nouvelle limite validée
          chatbotPersonality: _currentChatbotPersonality,
        ),
      );
    }
  }

  void _showPersonalityPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choisir la Personnalité'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _personalityOptions.length,
              itemBuilder: (BuildContext context, int index) {
                return RadioListTile<String>(
                  title: Text(_personalityOptions[index]),
                  value: _personalityOptions[index],
                  groupValue: _currentChatbotPersonality,
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _currentChatbotPersonality = value;
                      });
                      Navigator.of(context).pop(); // Fermer le dialogue après sélection
                    }
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gérer l'Assistant"),
        backgroundColor: isDarkMode ? Colors.grey[800] : Theme.of(context).colorScheme.primary,
        foregroundColor: isDarkMode ? Colors.white : Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt_rounded),
            tooltip: 'Enregistrer',
            onPressed: _saveSettings,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // Section Personnalité
          Card(
            elevation: isDarkMode ? 2 : 1,
            color: isDarkMode ? Colors.grey[850] : Theme.of(context).cardColor,
            child: ListTile(
              leading: Icon(Icons.psychology_alt_rounded, color: Theme.of(context).colorScheme.secondary),
              title: const Text("Style de Réponse / Personnalité"),
              subtitle: Text(_currentChatbotPersonality),
              trailing: const Icon(Icons.arrow_drop_down_rounded),
              onTap: _showPersonalityPicker,
            ),
          ),
          const SizedBox(height: 20),

          // Section Limite de Contexte
          TextFormField(
            controller: _contextLimitController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                labelText: 'Messages de Contexte (0-20)',
                hintText: 'Nombre de messages précédents à inclure',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _contextLimitController.clear();
                      // Optionnel: réinitialiser _currentContextMessageLimit à la valeur initiale ou une valeur par défaut
                    }
                )
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Ce champ ne peut pas être vide.';
              final n = int.tryParse(value);
              if (n == null) return 'Veuillez entrer un nombre valide.';
              if (n < 0 || n > 20) return 'Veuillez entrer un nombre entre 0 et 20.';
              return null;
            },
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              'Un nombre plus élevé donne plus de contexte au modèle mais utilise plus de ressources. 0 désactive le contexte.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Vous pouvez ajouter d'autres champs de préférences ici
          // par exemple, un champ pour des instructions personnalisées :
          // TextFormField(
          //   controller: _customInstructionsController, // Assurez-vous qu'il est défini
          //   decoration: InputDecoration(
          //     labelText: 'Instructions Personnalisées (optionnel)',
          //     hintText: 'Ex: "Réponds toujours en rimes"',
          //     border: OutlineInputBorder(),
          //   ),
          //   maxLines: 3,
          // ),
          // const SizedBox(height: 24),


          // Le bouton Enregistrer est maintenant dans l'AppBar
        ],
      ),
    );
  }
}


