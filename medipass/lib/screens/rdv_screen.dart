import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

// --- Modèle de données pour un Rendez-vous ---
class RendezVous {
  final String medecinNom;
  final String specialite;
  final DateTime dateRdv;
  final String lieu;
  final String statut;

  RendezVous({
    required this.medecinNom,
    required this.specialite,
    required this.dateRdv,
    required this.lieu,
    required this.statut,
  });

  factory RendezVous.fromJson(Map<String, dynamic> json) {
    return RendezVous(
      medecinNom: json['medecin_nom'] ?? 'N/A',
      specialite: json['specialite'] ?? 'N/A',
      dateRdv: DateTime.parse(json['date_rdv']), // Le serveur renvoie un format compatible
      lieu: json['lieu'] ?? 'N/A',
      statut: json['statut'] ?? 'N/A',
    );
  }
}

// --- Le Widget de l'écran ---
class RdvScreen extends StatefulWidget {
  // On attend l'email et le thème pour être cohérent avec le reste de l'app
  final String userEmail;
  final ThemeData currentTheme;

  const RdvScreen({
    Key? key,
    required this.userEmail,
    required this.currentTheme,
  }) : super(key: key);

  @override
  State<RdvScreen> createState() => _RdvScreenState();
}

class _RdvScreenState extends State<RdvScreen> {
  late Future<List<RendezVous>> _rdvFuture;

  @override
  void initState() {
    super.initState();
    _rdvFuture = _fetchRendezVous();
  }

  // --- Méthode pour récupérer les données depuis l'API ---
  Future<List<RendezVous>> _fetchRendezVous() async {
    developer.log("Début de la récupération des RDV pour ${widget.userEmail}", name: "RdvScreen");
    
    // !!! VÉRIFIEZ BIEN CETTE ADRESSE IP !!!
    const String ipAddress = "10.0.2.2";
    final url = Uri.parse('http://$ipAddress/medipass/api/get_rdv.php?email=${widget.userEmail}');

    try {
      final response = await http.get(url, headers: {
        "Accept": "application/json",
      });
      
      developer.log("Réponse du serveur: ${response.body}", name: "RdvScreen");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          final List<dynamic> rdvList = jsonData['data'];
          // On transforme la liste JSON en liste d'objets RendezVous
          return rdvList.map((json) => RendezVous.fromJson(json)).toList();
        } else {
          throw Exception('Erreur de l\'API: ${jsonData['message']}');
        }
      } else {
        throw Exception('Erreur du serveur: ${response.statusCode}');
      }
    } catch (e) {
      developer.log("Erreur critique: $e", name: "RdvScreen", error: e);
      // On propage l'erreur pour que le FutureBuilder puisse l'afficher
      throw Exception('Impossible de contacter le serveur: $e');
    }
  }

  // Helper pour formater la date
  String _formatDate(DateTime date) {
    // Simple formatage sans package intl
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}h${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    // On s'assure que tout l'écran utilise le bon thème
    return Theme(
      data: widget.currentTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mes Rendez-vous"),
          // La couleur est déjà gérée par le Theme
        ),
        body: FutureBuilder<List<RendezVous>>(
          future: _rdvFuture,
          builder: (context, snapshot) {
            // --- Cas 1: En chargement ---
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // --- Cas 2: Erreur ---
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      const Text(
                        "Une erreur est survenue",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${snapshot.error}",
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],                  ),
                ),
              );
            }

            // --- Cas 3: Données reçues, mais la liste est vide ---
            final rdvList = snapshot.data;
            if (rdvList == null || rdvList.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Aucun rendez-vous à venir.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            // --- Cas 4: On affiche la liste des rendez-vous ---
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: rdvList.length,
              itemBuilder: (context, index) {
                final rdv = rdvList[index];
                return Card(
                  elevation: 3.0,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rdv.specialite,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: widget.currentTheme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Avec ${rdv.medecinNom}",
                          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Icon(Icons.calendar_month_rounded, color: Colors.grey[600], size: 20),
                            const SizedBox(width: 8),
                            Text(_formatDate(rdv.dateRdv), style: const TextStyle(fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(rdv.lieu, style: const TextStyle(fontSize: 15)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}