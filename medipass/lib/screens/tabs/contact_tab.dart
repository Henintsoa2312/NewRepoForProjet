import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as developer;
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContactTab extends StatelessWidget {
  const ContactTab({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      developer.log("Impossible de lancer l'URL: $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Icon(Icons.help_outline_rounded, size: 50, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                const Text(
                  "Besoin d'aide ?",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Nous sommes là pour vous aider. Contactez-nous via les moyens ci-dessous ou consultez notre FAQ.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        Text("Contact Direct", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildContactTile(
          context: context,
          icon: Icons.email_outlined,
          title: "Envoyer un e-mail",
          subtitle: "support@medipass.mg",
          onTap: () => _launchUrl("mailto:support@medipass.mg?subject=Support Medipass"),
        ),
        _buildContactTile(
          context: context,
          icon: Icons.phone_outlined,
          title: "Appeler le support",
          subtitle: "+261 34 28 254 08",
          onTap: () => _launchUrl("tel:+261342825408"),
        ),
        _buildContactTile(
          context: context,
          icon: Icons.location_on_outlined,
          title: "Notre adresse",
          subtitle: "101, Antananarivo, Madagascar",
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fonctionnalité de carte à venir.")));
           },
        ),

        const Divider(height: 40, thickness: 1),

        Text("Foire Aux Questions", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildFaqItem(
            context: context,
            question: "Comment mettre à jour ma photo de profil ?",
            answer: "Allez dans le menu latéral (en cliquant sur l’icône en haut à gauche), sélectionnez ‘Mon Profil’, puis appuyez sur l’icône de photo pour choisir une nouvelle image."
        ),
        _buildFaqItem(
            context: context,
            question: "Où puis-je voir mes résultats d\'analyse ?",
            answer: "Dans le menu latéral, sélectionnez ‘Mes Analyses’. Si le statut d’une analyse est ‘Résultats disponibles’, un bouton apparaîtra pour vous permettre de les consulter."
        ),
        _buildFaqItem(
            context: context,
            question: "L\'application est-elle gratuite ?",
            answer: "Oui, l\'application Medipass est entièrement gratuite pour les patients. Les frais concernent uniquement les services des laboratoires et professionnels de santé."
        ),
      ],
    );
  }

  Widget _buildContactTile({required BuildContext context, required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
  
  Widget _buildFaqItem({required BuildContext context, required String question, required String answer}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        iconColor: theme.colorScheme.primary,
        collapsedIconColor: theme.textTheme.bodyMedium?.color,
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: TextStyle(fontSize: 15, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8))),
          ),
        ],
      ),
    );
  }
}
