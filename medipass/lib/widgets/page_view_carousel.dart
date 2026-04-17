// lib/widgets/page_view_carousel.dart
import 'dart:async';
import 'package:flutter/material.dart';

// --- PAS DE DÉPENDANCES EXTERNES ---

// 1. Modèle de données (inchangé)
class Laboratoire {
  final String nom;
  final String adresse;
  final String contact;

  const Laboratoire({
    required this.nom,
    required this.adresse,
    required this.contact,
  });
}

// 2. Widget de carte (inchangé, mais renommé pour la clarté)
class LaboCard extends StatelessWidget {
  final Laboratoire laboratoire;

  const LaboCard({Key? key, required this.laboratoire}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                laboratoire.nom,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(context, Icons.location_on_outlined, laboratoire.adresse),
                      const SizedBox(height: 10),
                      _buildInfoRow(context, Icons.phone_outlined, laboratoire.contact),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}

// 3. Le nouveau Carrousel avec PageView
class PageViewCarousel extends StatefulWidget {
  const PageViewCarousel({Key? key}) : super(key: key);

  @override
  _PageViewCarouselState createState() => _PageViewCarouselState();
}

class _PageViewCarouselState extends State<PageViewCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  Timer? _timer;

  final List<Laboratoire> laboratoires = const [
    Laboratoire(
      nom: "CMM Labo",
      adresse: "Mahamasina, Lot VF 13 (en face de l’Institution Sainte Famille)",
      contact: "+261 34 92 631 50",
    ),
    Laboratoire(
      nom: "Health Labo",
      adresse: "Route d’Analamahitsy (à côté du Ministère de la Communication)",
      contact: "+261 34 22 299 10 / +261 33 12 169 69",
    ),
    Laboratoire(
      nom: "LAMA",
      adresse: "Avenue Gal Gabriel, bâtiment EDBM, Antaninarenina",
      contact: "+261 20 22 681 21 / +261 20 22 670 40",
    ),
    Laboratoire(
      nom: "Laboratoire d’Anosy Avaratra",
      adresse: "Ankadikely (RN3) et Ambatonakanga (24h/7j)",
      contact: "RN3: +261 20 24 569 01 / 24h/7j: +261 34 27 746 30",
    ),
    Laboratoire(
      nom: "Laborama",
      adresse: "Rue Radama 1er, Tsaralalàna, 11 Lalana Radama",
      contact: "+261 20 22 336 99",
    ),
    Laboratoire(
      nom: "Institut Pasteur de Madagascar",
      adresse: "Avaradoha (principal) et centre de prélèvement à Ankorondrano",
      contact: "+261 20 22 401 64 / +261 20 22 412 72",
    ),
    Laboratoire(
      nom: "Labo Chimie Madagascar",
      adresse: "Aingasoa PK20 – RN1, Ambatomirahavavy. Annexe à Ankorondrano.",
      contact: "+261 32 43 229 11",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < laboratoires.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.0,
      child: PageView.builder(
        controller: _pageController,
        itemCount: laboratoires.length,
        itemBuilder: (context, index) {
          // Effet de zoom sur la carte du milieu
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 0.0;
              if (_pageController.position.haveDimensions) {
                value = index - (_pageController.page ?? 0);
                value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
              }
              return Center(
                child: SizedBox(
                  height: Curves.easeOut.transform(value) * 220,
                  width: Curves.easeOut.transform(value) * 400,
                  child: child,
                ),
              );
            },
            child: LaboCard(laboratoire: laboratoires[index]),
          );
        },
        onPageChanged: (int index) {
          setState(() {
            _currentPage = index;
          });
        },
      ),
    );
  }
}
