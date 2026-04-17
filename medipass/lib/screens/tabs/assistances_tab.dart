import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as developer;
import '../mistral_chat_screen.dart';
import '../doctor_chat_screen.dart';

class AssistancesTab extends StatelessWidget {
  const AssistancesTab({super.key});

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
        // ... (Carte Assistant Virtuel inchangée) ...
        Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MistralChatScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 40, color: theme.colorScheme.secondary),
                  const SizedBox(height: 12),
                  const Text(
                    "Assistant Virtuel Medipass",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Posez vos questions sur nos services, les laboratoires ou le fonctionnement de l'application.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // CARTE MESSAGERIE DOCTEUR (COULEURS CORRIGÉES)
        Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: theme.primaryColor.withOpacity(0.5), width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias, 
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DoctorChatScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(Icons.forum_outlined, size: 40, color: theme.primaryColor),
                  const SizedBox(height: 12),
                  Text(
                    "Messagerie Docteur",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Échangez directement avec un médecin après avoir obtenu un consentement.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // ... (Autres canaux de support) ...
        Text(
          "Autres Canaux de Support",
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.contact_phone_rounded, color: theme.colorScheme.secondary),
                title: const Text("Support téléphonique"),
                subtitle: const Text("Appelez-nous au +261 34 28 254 08"),
                onTap: () => _launchUrl("tel:+261342825408"),
              ),
            ],
          ),
        )
      ],
    );
  }
}
