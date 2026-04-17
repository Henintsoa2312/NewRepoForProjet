import 'package:medipass/screens/games/quiz_game_screen.dart';

// Base de données de toutes les questions du quiz.
// Vous pouvez facilement ajouter de nouvelles questions ici.

const List<Question> allQuizQuestions = [
  // --- Nutrition ---
  Question(
    text: "Quel aliment est le plus riche en Vitamine C ?",
    options: ["Orange", "Poivron rouge", "Kiwi", "Brocoli"],
    correctAnswerIndex: 1,
  ),
  Question(
    text: "Lequel de ces aliments est une bonne source de protéines végétales ?",
    options: ["Pomme", "Riz blanc", "Lentilles", "Carotte"],
    correctAnswerIndex: 2,
  ),
  Question(
    text: "Quelle est la principale fonction des fibres alimentaires ?",
    options: ["Donner de l\'énergie", "Construire du muscle", "Aider la digestion", "Hydrater le corps"],
    correctAnswerIndex: 2,
  ),
  Question(
    text: "Les Oméga-3 sont des...",
    options: ["Sucres rapides", "Vitamines", "Acides gras essentiels", "Protéines"],
    correctAnswerIndex: 2,
  ),
  Question(
    text: "Quel nutriment est la principale source d\'énergie pour le corps ?",
    options: ["Protéines", "Lipides", "Vitamines", "Glucides"],
    correctAnswerIndex: 3,
  ),

  // --- Activité Physique ---
  Question(
    text: "Quel est le principal bienfait d\'une activité physique régulière ?",
    options: ["Regarder plus de séries", "Améliorer la santé cardiovasculaire", "Manger plus de gâteaux", "Dormir moins"],
    correctAnswerIndex: 1,
  ),
  Question(
    text: "Combien de minutes d\'activité modérée sont recommandées par semaine ?",
    options: ["30 minutes", "75 minutes", "150 minutes", "300 minutes"],
    correctAnswerIndex: 2,
  ),
  Question(
    text: "Qu\'est-ce que l\'échauffement avant le sport permet d\'éviter ?",
    options: ["La transpiration", "La faim", "Les blessures", "La fatigue"],
    correctAnswerIndex: 2,
  ),

  // --- Sommeil ---
  Question(
    text: "Laquelle de ces affirmations sur le sommeil est VRAIE ?",
    options: ["Les adultes ont besoin de 4h de sommeil", "Faire du sport juste avant de dormir aide", "Les écrans favorisent l\'endormissement", "Il consolide la mémoire et l\'apprentissage"],
    correctAnswerIndex: 3,
  ),
  Question(
    text: "Quelle hormone, favorisant le sommeil, est sensible à la lumière ?",
    options: ["Adrénaline", "Mélatonine", "Insuline", "Cortisol"],
    correctAnswerIndex: 1,
  ),

  // --- Hydratation ---
  Question(
    text: "Combien de verres d'eau est-il recommandé de boire par jour en moyenne ?",
    options: ["2 verres (0.5L)", "4 verres (1L)", "8 verres (2L)", "12 verres (3L)"],
    correctAnswerIndex: 2,
  ),
  Question(
    text: "Lequel de ces signes peut indiquer une déshydratation ?",
    options: ["Peau très claire", "Sensation de faim", "Maux de tête", "Avoir froid"],
    correctAnswerIndex: 2,
  ),

  // --- Bien-être général ---
  Question(
    text: "Quelle activité est connue pour réduire le stress ?",
    options: ["La méditation", "Boire du café", "Regarder les infos en continu", "Vérifier ses e-mails"],
    correctAnswerIndex: 0,
  ),
  Question(
    text: "Lequel de ces éléments n\'est PAS considéré comme un des piliers de la santé ?",
    options: ["Alimentation", "Activité physique", "Sommeil", "Richesse matérielle"],
    correctAnswerIndex: 3,
  ),

  // --- Mythes & Réalités ---
  Question(
    text: "Vrai ou Faux : Manger du chocolat donne des boutons.",
    options: ["Vrai", "Faux"],
    correctAnswerIndex: 1,
  ),
  Question(
    text: "Vrai ou Faux : Se 'craquer' les doigts provoque de l\'arthrite.",
    options: ["Vrai", "Faux"],
    correctAnswerIndex: 1,
  ),
  Question(
    text: "Vrai ou Faux : Sauter un repas aide à perdre du poids plus vite.",
    options: ["Vrai", "Faux"],
    correctAnswerIndex: 1,
  ),
  Question(
    text: "Quel type de graisse est considéré comme 'bon' pour la santé ?",
    options: ["Graisses saturées", "Graisses trans", "Graisses insaturées", "Toutes les graisses sont mauvaises"],
    correctAnswerIndex: 2,
  ),
  Question(
    text: "Qu\'est-ce que l\'IMC ?",
    options: ["Indice de Masse Corporelle", "Indice Médical Certifié", "Intensité Musculaire Cardiaque"],
    correctAnswerIndex: 0,
  ),
  Question(
    text: "L\'exposition au soleil aide le corps à produire quelle vitamine ?",
    options: ["Vitamine C", "Vitamine A", "Vitamine D", "Vitamine B12"],
    correctAnswerIndex: 2,
  ),
];
