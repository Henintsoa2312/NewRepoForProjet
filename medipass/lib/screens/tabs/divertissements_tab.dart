import 'package:flutter/material.dart';
import 'package:medipass/screens/games/games_list_screen.dart';
import 'package:medipass/screens/games/quiz_game_screen.dart';

class DivertissementsTab extends StatelessWidget {
  const DivertissementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: <Widget>[
          _buildGridItem(context, Icons.sports_esports_rounded, 'Jeux', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GamesListScreen(currentTheme: theme),
              ),
            );
          }),
          _buildGridItem(context, Icons.article_rounded, 'Articles & Blogs', (){}),
          _buildGridItem(context, Icons.lightbulb_rounded, 'Quiz & Défis', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizGameScreen(currentTheme: theme),
              ),
            );
          }),
          _buildGridItem(context, Icons.extension_rounded, 'Puzzles', (){
            // Action pour les puzzles (sera ajoutée plus tard)
          }),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: isDarkMode ? 4 : 2,
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 40, color: theme.colorScheme.secondary),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
