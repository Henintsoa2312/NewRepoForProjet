import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'package:url_launcher/url_launcher.dart';

// --- Modèle de données pour une Analyse ---
class Analyse {
  final String nomAnalyse;
  final String nomLabo;
  final DateTime dateDemande;
  final String statut;
  final String? resultatUrl; // Peut être nul

  Analyse({
    required this.nomAnalyse,
    required this.nomLabo,
    required this.dateDemande,
    required this.statut,
    this.resultatUrl,
  });

  factory Analyse.fromJson(Map<String, dynamic> json) {
    return Analyse(
      nomAnalyse: json['nom_analyse'] ?? 'N/A',
      nomLabo: json['nom_labo'] ?? 'N/A',
      dateDemande: DateTime.parse(json['date_demande']),
      statut: json['statut'] ?? 'N/A',
      resultatUrl: json['resultat_url'],
    );
  }
}

// --- Le Widget de l'écran ---
class AnalysesScreen extends StatefulWidget {
  final String userEmail;
  final ThemeData currentTheme;

  const AnalysesScreen({
    Key? key,
    required this.userEmail,
    required this.currentTheme,
  }) : super(key: key);

  @override
  State<AnalysesScreen> createState() => _AnalysesScreenState();
}

class _AnalysesScreenState extends State<AnalysesScreen> {
  late Future<List<Analyse>> _analysesFuture;

  @override
  void initState() {
    super.initState();
    _analysesFuture = _fetchAnalyses();
  }

  Future<List<Analyse>> _fetchAnalyses() async {
    const String ipAddress = "10.0.2.2";
    final url = Uri.parse('http://$ipAddress/medipass/api/get_analyses.php?email=${widget.userEmail}');

    try {
      final response = await http.get(url, headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> analysesList = jsonData['data'];
          return analysesList.map((json) => Analyse.fromJson(json)).toList();
        } else {
          throw Exception('Erreur de l\'API: ${jsonData['message']}');
        }
      } else {
        throw Exception('Erreur du serveur: ${response.statusCode}');
      }
    } catch (e) {
      developer.log("Erreur fetchAnalyses: $e", name: "AnalysesScreen");
      throw Exception('Impossible de contacter le serveur: $e');
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null) return;
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      developer.log("Impossible de lancer l'URL: $urlString");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.currentTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mes Analyses"),
        ),
        body: FutureBuilder<List<Analyse>>(
          future: _analysesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text("Erreur: ${snapshot.error}", textAlign: TextAlign.center),
              );
            }

            final analysesList = snapshot.data;
            if (analysesList == null || analysesList.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_off_outlined, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Aucune analyse trouvée.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: analysesList.length,
              itemBuilder: (context, index) {
                final analyse = analysesList[index];
                final bool isCompleted = analyse.statut == 'Résultats disponibles';

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
                          analyse.nomAnalyse,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: widget.currentTheme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Laboratoire: ${analyse.nomLabo}",
                          style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, color: Colors.grey[600], size: 20),
                            const SizedBox(width: 8),
                            Text("Demandée le: ${_formatDate(analyse.dateDemande)}", style: const TextStyle(fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              isCompleted ? Icons.check_circle_outline : Icons.hourglass_top_outlined,
                              color: isCompleted ? Colors.green : Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text("Statut: ${analyse.statut}", style: const TextStyle(fontSize: 15)),
                          ],
                        ),
                        if (isCompleted && analyse.resultatUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.picture_as_pdf_outlined),
                              label: const Text("Voir les résultats"),
                              onPressed: () => _launchUrl(analyse.resultatUrl),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.currentTheme.colorScheme.secondary,
                                foregroundColor: Colors.white,
                              ),
                            ),
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
