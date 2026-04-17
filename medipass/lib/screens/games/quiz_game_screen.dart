import 'dart:math';
import 'package:flutter/material.dart';
import 'package:medipass/data/quiz_questions.dart';

class Question {
  final String text;
  final List<String> options;
  final int correctAnswerIndex;

  const Question({required this.text, required this.options, required this.correctAnswerIndex});
}

class QuizGameScreen extends StatefulWidget {
  final ThemeData currentTheme;
  const QuizGameScreen({Key? key, required this.currentTheme}) : super(key: key);

  @override
  _QuizGameScreenState createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> {
  late List<Question> _currentRoundQuestions;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _answered = false;
  int? _selectedAnswerIndex;

  @override
  void initState() {
    super.initState();
    _startNewRound();
  }

  void _startNewRound() {
    final allQuestions = List<Question>.from(allQuizQuestions);
    allQuestions.shuffle(Random());

    setState(() {
      _currentRoundQuestions = allQuestions.take(5).toList();
      _currentQuestionIndex = 0;
      _score = 0;
      _answered = false;
      _selectedAnswerIndex = null;
    });
  }

  void _handleAnswer(int selectedIndex) {
    if (_answered) return;

    setState(() {
      _answered = true;
      _selectedAnswerIndex = selectedIndex;
      if (selectedIndex == _currentRoundQuestions[_currentQuestionIndex].correctAnswerIndex) {
        _score++;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _currentRoundQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answered = false;
        _selectedAnswerIndex = null;
      });
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Niveau terminé !"),
        content: Text("Votre score : $_score / ${_currentRoundQuestions.length}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startNewRound();
            },
            child: const Text("Niveau suivant"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text("Quitter"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentRoundQuestions.isEmpty) {
      return Theme(
          data: widget.currentTheme,
          child: Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()))
      );
    }

    final Question currentQuestion = _currentRoundQuestions[_currentQuestionIndex];
    return Theme(
      data: widget.currentTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Défi: ${_currentQuestionIndex + 1} / ${_currentRoundQuestions.length}"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                currentQuestion.text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              ...List.generate(currentQuestion.options.length, (index) {
                return _buildOptionButton(currentQuestion, index);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(Question question, int index) {
    final bool isSelected = _selectedAnswerIndex == index;
    final bool isCorrect = index == question.correctAnswerIndex;
    final bool isDarkMode = widget.currentTheme.brightness == Brightness.dark;

    Color buttonColor;
    Color textColor;
    BorderSide border = BorderSide.none;

    if (_answered) {
      if (isCorrect) {
        // La bonne réponse (sélectionnée ou non)
        buttonColor = isDarkMode ? Colors.green[800]! : Colors.green[200]!;
        textColor = isDarkMode ? Colors.white : Colors.black87;
      } else if (isSelected && !isCorrect) {
        // La mauvaise réponse que l'utilisateur a sélectionnée
        buttonColor = isDarkMode ? Colors.red[800]! : Colors.red[200]!;
        textColor = isDarkMode ? Colors.white : Colors.black87;
      } else {
        // Les autres mauvaises réponses (non sélectionnées)
        buttonColor = isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;
        textColor = isDarkMode ? Colors.grey[600]! : Colors.grey[700]!;
      }
    } else {
      // État initial avant la réponse
      buttonColor = widget.currentTheme.cardColor;
      textColor = widget.currentTheme.textTheme.bodyLarge!.color!;
      border = BorderSide(color: widget.currentTheme.colorScheme.primary, width: 1);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () => _handleAnswer(index),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor, 
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: border,
          ),
          elevation: 2,
        ),
        child: Text(question.options[index], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
