import 'package:flutter/material.dart';
import 'package:medipass/widgets/page_view_carousel.dart';
import 'package:medipass/screens/profile_screen.dart';
import 'package:medipass/screens/map_screen.dart';
import 'package:medipass/screens/analyses_screen.dart';
import 'package:medipass/screens/rdv_screen.dart';
import 'package:medipass/services/auth_service.dart';
import 'package:medipass/screens/auth_screen.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// --- IMPORTS POUR LA LOGIQUE D'API ET DE DÉBOGAGE ---
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

// Importer les tabs
import 'tabs/assistances_tab.dart';
import 'tabs/contact_tab.dart';
import 'tabs/divertissements_tab.dart';
import 'tabs/parametres_tab.dart';

// --- MODÈLE PATIENT ---
class Patient {
  final String nom;
  final String prenom;
  final String email;
  final String? dateNaissance;
  final String? sexe;
  final String? photoUrl;

  Patient({
    required this.nom,
    required this.prenom,
    required this.email,
    this.dateNaissance,
    this.sexe,
    this.photoUrl,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      nom: json['nom'] ?? 'N/A',
      prenom: json['prenom'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      dateNaissance: json['date_naissance'],
      sexe: json['sexe'],
      photoUrl: json['photo_url'],
    );
  }
}

class Laboratoire {
  final String nom;
  final String adresse;
  Laboratoire({required this.nom, required this.adresse});
}

// --- WIDGET ACCUEILTAB ---
class AccueilTab extends StatelessWidget {
  final Future<Patient> patientFuture;

  AccueilTab({super.key, required this.patientFuture}); // 'const' retiré

  final Map<String, List<Laboratoire>> laboratoiresParVille = {
    'Toamasina': [
      Laboratoire(nom: 'CTB (Centre Technique Biomédical)', adresse: 'Lot 27 bis Anjoma'),
      Laboratoire(nom: 'Laboratoire d’Autocontrôle et d’Analyse Alimentaire GC2A', adresse: 'Boulevard Ratsimilaho Ampasimazava'),
      Laboratoire(nom: 'Annexe LHAE (Institut Pasteur)', adresse: 'Toamasina'),
    ],
    'Mahajanga': [
      Laboratoire(nom: 'CTB (Centre Technique Biomédical)', adresse: 'Ampasika'),
      Laboratoire(nom: 'Laboratoire de Nosy-Be (LNB)', adresse: 'Mahajanga'),
    ],
    'Nosy Be': [
      Laboratoire(nom: 'LNB', adresse: 'Immeuble “ARO IMMOBILIER”, Hell Ville'),
    ],
    'Moramanga': [
      Laboratoire(nom: 'Centre d’Analyses Médicales de Moramanga', adresse: 'Lot A 193 Camp des Mariés'),
    ],
    'Fianarantsoa': [
      Laboratoire(nom: 'Centre d’Analyses Médicales de Fianarantsoa (CAMF)', adresse: 'Fianarantsoa'),
      Laboratoire(nom: 'CTB antenne Fianarantsoa', adresse: 'Fianarantsoa'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView(
        children: [
          const SizedBox(height: 24),
          FutureBuilder<Patient>(
            future: patientFuture,
            builder: (context, snapshot) {
              String nomPatient = "";
              if (snapshot.hasData && snapshot.data!.prenom != 'N/A') {
                nomPatient = ", ${snapshot.data!.prenom}";
              }
              return Text(
                'Bienvenue sur Medipass$nomPatient !', // Texte en dur
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              );
            },
          ),
          const SizedBox(height: 30),
          Text(
            "Laboratoires d'analyses à Antananarivo", // Texte en dur
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 15),
          const PageViewCarousel(),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.explore_outlined),
            label: const Text('Map des laboratoires'), // Texte en dur
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapScreen(currentTheme: theme)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            "Autres laboratoires à Madagascar", // Texte en dur
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...laboratoiresParVille.entries.map((entry) {
            String ville = entry.key;
            List<Laboratoire> labos = entry.value;

            return Card(
              elevation: 2.0,
              margin: const EdgeInsets.only(bottom: 16.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ville,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const Divider(height: 20),
                    ...labos.map((labo) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.science_outlined, size: 16, color: subtitleColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    labo.nom,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 24.0, top: 4.0),
                              child: Text(
                                labo.adresse,
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// --- HOMESCREEN MIS À JOUR ---
class HomeScreen extends StatefulWidget {
  final String userEmail;
  const HomeScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;
  late Future<Patient> _patientFuture;
  late List<Widget> _pageContents;

  @override
  void initState() {
    super.initState();
    _patientFuture = _fetchUserData();
    _pageContents = [
      AccueilTab(patientFuture: _patientFuture),
      const AssistancesTab(),
      const ContactTab(),
      const DivertissementsTab(),
      const ParametresTab(),
    ];
  }

  void _refreshUserData() {
    developer.log("Rafraîchissement des données utilisateur...", name: "HomeScreen");
    setState(() {
      _patientFuture = _fetchUserData();
    });
  }

  Future<Patient> _fetchUserData() async {
    const String ipAddress = "10.0.2.2";
    final url = Uri.parse('http://$ipAddress/medipass/api/get_user_data.php?email=${widget.userEmail}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success']) {
          return Patient.fromJson(jsonData['data']);
        } else {
          throw Exception('API Error: ${jsonData['message']}');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      developer.log("Erreur de récupération des données utilisateur: $e", name: "HomeScreen", error: e);
      throw Exception('Failed to contact server: $e');
    }
  }
  
  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Se déconnecter', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  final List<String> _pageTitles = ['Accueil', 'Assistances', 'Contact', 'Divertissements', 'Paramètres'];

  final List<Map<String, dynamic>> _navItems = [
    {'label': 'Accueil', 'icon': Icons.home_rounded, 'selected_icon': Icons.home_filled},
    {'label': 'Assistances', 'icon': Icons.support_agent_outlined, 'selected_icon': Icons.support_agent_rounded},
    {'label': 'Contact', 'icon': Icons.contacts_outlined, 'selected_icon': Icons.contacts_rounded},
    {'label': 'Divertissements', 'icon': Icons.videogame_asset_outlined, 'selected_icon': Icons.videogame_asset_rounded},
    {'label': 'Paramètres', 'icon': Icons.settings_outlined, 'selected_icon': Icons.settings_rounded},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
        appBar: AppBar(
          title: Text(_pageTitles[_selectedIndex]),
          elevation: 2.0,
          backgroundColor: theme.primaryColor,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: InkWell(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        userEmail: widget.userEmail,
                        currentTheme: theme,
                      ),
                    ),
                  );

                  if (result == true) {
                    _refreshUserData();
                  }
                },
                customBorder: const CircleBorder(),
                child: FutureBuilder<Patient>(
                  future: _patientFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data?.photoUrl != null && snapshot.data!.photoUrl!.isNotEmpty) {
                      return CircleAvatar(
                        key: ValueKey(snapshot.data!.photoUrl!),
                        radius: 20,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: NetworkImage(snapshot.data!.photoUrl!),
                      );
                    }
                    return CircleAvatar(
                      radius: 20,
                      backgroundColor: isDarkMode ? Colors.grey[700] : Colors.white.withOpacity(0.8),
                      child: Icon(Icons.person, color: isDarkMode ? Colors.white70 : theme.primaryColor),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              FutureBuilder<Patient>(
                future: _patientFuture,
                builder: (context, snapshot) {
                  Widget accountName;
                  Widget accountPicture;

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    accountName = const Text("Chargement...");
                    accountPicture = CircleAvatar( backgroundColor: Colors.white, child: Padding( padding: const EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2.0, color: theme.primaryColor),),);
                  } else if (snapshot.hasData) {
                    final patient = snapshot.data!;
                    accountName = Text(patient.prenom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),);
                    accountPicture = CircleAvatar(
                      key: ValueKey(patient.photoUrl ?? patient.prenom),
                      radius: 40,
                      backgroundColor: Colors.white.withOpacity(0.9),
                      backgroundImage: (patient.photoUrl != null && patient.photoUrl!.isNotEmpty) ? NetworkImage(patient.photoUrl!) : null,
                      child: (patient.photoUrl == null || patient.photoUrl!.isEmpty) ? Text(patient.prenom.isNotEmpty ? patient.prenom[0].toUpperCase() : 'P', style: TextStyle(fontSize: 40.0, color: theme.primaryColor),) : null,
                    );
                  } else {
                    accountName = const Text("Erreur", style: TextStyle(color: Colors.red));
                    accountPicture = const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.error_outline, color: Colors.red),);
                  }

                  return UserAccountsDrawerHeader(
                    accountName: accountName,
                    accountEmail: Text(widget.userEmail),
                    currentAccountPicture: accountPicture,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.biotech_outlined),
                title: const Text('Mes Analyses en Cours'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AnalysesScreen(userEmail: widget.userEmail, currentTheme: theme)));
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month_outlined),
                title: const Text('Mes Rendez-vous'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RdvScreen(userEmail: widget.userEmail, currentTheme: theme)));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Mon Profil'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(userEmail: widget.userEmail, currentTheme: theme),
                    ),
                  );
                  if (result == true) {
                    _refreshUserData();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Paramètres'),
                onTap: () {
                  Navigator.pop(context);
                  _onItemTapped(4);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Se déconnecter'),
                onTap: _showLogoutDialog,
              ),
            ],
          ),
        ),
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _selectedIndex,
            children: _pageContents,
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 20.0),
          child: Container(
            height: 65,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.grey[850]!.withOpacity(0.95)
                  : theme.primaryColor.withOpacity(0.95),
              borderRadius: BorderRadius.circular(32.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _navItems.asMap().entries.map((entry) {
                int idx = entry.key;
                Map<String, dynamic> item = entry.value;
                bool isSelected = _selectedIndex == idx;
                return InkWell(
                  onTap: () => _onItemTapped(idx),
                  borderRadius: BorderRadius.circular(30),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? (item['selected_icon'] as IconData) : (item['icon'] as IconData),
                          color: isSelected ? Colors.white : (isDarkMode ? Colors.grey[400] : Colors.white.withOpacity(0.7)),
                          size: isSelected ? 28 : 24,
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: isSelected ? 14 : 0,
                          child: isSelected
                              ? Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              item['label'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                              : null,
                        )
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );
  }
}
