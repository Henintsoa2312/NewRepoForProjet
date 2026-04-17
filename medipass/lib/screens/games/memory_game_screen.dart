import 'dart:async';
import 'package:flutter/material.dart';

// Modèle pour une seule carte
class CardItem {
  final IconData icon;
  final int value; // Valeur unique pour identifier la paire
  bool isFlipped = false;
  bool isMatched = false;

  CardItem({required this.icon, required this.value});
}

class MemoryGameScreen extends StatefulWidget {
  final ThemeData currentTheme;
  const MemoryGameScreen({Key? key, required this.currentTheme}) : super(key: key);

  @override
  _MemoryGameScreenState createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  late List<CardItem> _cards;
  CardItem? _previousCard;
  bool _isChecking = false;
  int _matchesFound = 0;
  final int _gridSize = 4; // Grille de 4x4

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    _matchesFound = 0;
    _previousCard = null;
    final List<IconData> icons = [
      Icons.favorite_border,
      Icons.apple,
      Icons.spa_outlined,
      Icons.self_improvement,
      Icons.bedtime_outlined,
      Icons.directions_run,
      Icons.local_florist_outlined,
      Icons.water_drop_outlined,
    ];

    _cards = [];
    for (int i = 0; i < (_gridSize * _gridSize) / 2; i++) {
      _cards.add(CardItem(icon: icons[i], value: i));
      _cards.add(CardItem(icon: icons[i], value: i));
    }
    _cards.shuffle();
  }

  void _onCardTapped(int index) {
    if (_isChecking || _cards[index].isFlipped || _cards[index].isMatched) return;

    setState(() {
      _cards[index].isFlipped = true;
    });

    if (_previousCard == null) {
      _previousCard = _cards[index];
    } else {
      _isChecking = true;
      if (_previousCard!.value == _cards[index].value) {
        setState(() {
          _previousCard!.isMatched = true;
          _cards[index].isMatched = true;
          _matchesFound++;
        });
        _previousCard = null;
        _isChecking = false;

        if (_matchesFound == (_gridSize * _gridSize) / 2) {
          _showWinDialog();
        }
      } else {
        Timer(const Duration(milliseconds: 700), () {
          setState(() {
            _previousCard!.isFlipped = false;
            _cards[index].isFlipped = false;
            _previousCard = null;
            _isChecking = false;
          });
        });
      }
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Félicitations !"),
          content: const Text("Vous avez trouvé toutes les paires."),
          actions: <Widget>[
            TextButton(
              child: const Text("Rejouer"),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _setupGame();
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.currentTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Jeu de Mémoire"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _gridSize,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _cards.length,
            itemBuilder: (context, index) {
              return _buildCard(index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(int index) {
    final card = _cards[index];
    final cardColor = widget.currentTheme.cardColor;
    final primaryColor = widget.currentTheme.colorScheme.primary;
    final secondaryColor = widget.currentTheme.colorScheme.secondary;

    return GestureDetector(
      onTap: () => _onCardTapped(index),
      child: Card(
        elevation: 4,
        color: card.isFlipped ? cardColor : secondaryColor,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: card.isFlipped
              ? Icon(
                  card.icon,
                  key: ValueKey('icon_$index'),
                  size: 40,
                  color: card.isMatched ? Colors.green : primaryColor,
                )
              : Icon(
                  Icons.question_mark_rounded,
                  key: ValueKey('placeholder_$index'),
                  size: 40,
                  color: Colors.white.withOpacity(0.8),
                ),
        ),
      ),
    );
  }
}
