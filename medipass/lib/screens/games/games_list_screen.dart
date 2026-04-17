import 'package:flutter/material.dart';
import 'package:medipass/screens/games/memory_game_screen.dart';

class GamesListScreen extends StatelessWidget {
  final ThemeData currentTheme;
  const GamesListScreen({Key? key, required this.currentTheme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: currentTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Choisir un jeu"),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          children: [
            _buildGameTile(
              context,
              icon: Icons.memory,
              title: "Jeu de Mémoire",
              subtitle: "Trouvez les paires d'icônes le plus vite possible.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MemoryGameScreen(currentTheme: currentTheme),
                  ),
                );
              },
            ),
            _buildGameTile(
              context,
              icon: Icons.extension_outlined,
              title: "Puzzle Relaxant",
              subtitle: "Reconstituez l'image pièce par pièce.",
              isEnabled: false, // On désactive le jeu en attendant son développement
              onTap: () {},
            ),
            _buildGameTile(
              context,
              icon: Icons.grid_on,
              title: "Mots Mêlés Médical",
              subtitle: "Trouvez les mots cachés sur le thème de la santé.",
              isEnabled: false, // On désactive le jeu
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameTile(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isEnabled = true, // Paramètre pour activer/désactiver
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: ListTile(
        leading: Icon(icon, size: 40, color: isEnabled ? Theme.of(context).colorScheme.primary : Colors.grey),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isEnabled ? null : Colors.grey)),
        subtitle: Text(subtitle, style: TextStyle(color: isEnabled ? null : Colors.grey)),
        trailing: isEnabled ? const Icon(Icons.chevron_right) : null,
        onTap: isEnabled ? onTap : null, // N'assigne onTap que si le jeu est activé
        enabled: isEnabled,
      ),
    );
  }
}
