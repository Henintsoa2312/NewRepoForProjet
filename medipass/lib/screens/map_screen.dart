import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;

// Classe pour représenter les informations d'un laboratoire
class LaboMarker {
  final String id;
  final String name;
  final String address;
  final LatLng position;

  LaboMarker({
    required this.id,
    required this.name,
    required this.address,
    required this.position,
  });
}

class MapScreen extends StatefulWidget {
  final ThemeData currentTheme;

  const MapScreen({Key? key, required this.currentTheme}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-18.879190, 47.507905),
    zoom: 13.0,
  );

  final Set<Marker> _markers = {};

  final List<LaboMarker> _laboList = [
    LaboMarker(
      id: 'labo_esca',
      name: "Laboratoire d'Analyses Médicales Esca",
      address: 'Antanimena, Antananarivo',
      position: const LatLng(-18.9039, 47.5222),
    ),
    LaboMarker(
      id: 'institut_pasteur',
      name: 'Institut Pasteur de Madagascar',
      address: 'Avaradoha, Antananarivo',
      position: const LatLng(-18.8928, 47.5255),
    ),
    LaboMarker(
      id: 'labo_hjra',
      name: 'Laboratoire HJRA',
      address: 'Ampefiloha, Antananarivo',
      position: const LatLng(-18.9174, 47.5195),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  void _createMarkers() {
    setState(() {
      for (var labo in _laboList) {
        _markers.add(
          Marker(
            markerId: MarkerId(labo.id),
            position: labo.position,
            infoWindow: InfoWindow(
              title: labo.name,
              snippet: labo.address,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.currentTheme, // Appliquer le thème à tout l'écran
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Explorer les laboratoires"),
        ),
        body: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _initialPosition,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            // Appliquer un style de carte sombre si le thème est sombre
            if (widget.currentTheme.brightness == Brightness.dark) {
              controller.setMapStyle('''[
                {"elementType":"geometry","stylers":[{"color":"#242f3e"}]},
                {"elementType":"labels.text.fill","stylers":[{"color":"#746855"}]},
                {"elementType":"labels.text.stroke","stylers":[{"color":"#242f3e"}]},
                {"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},
                {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},
                {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#263c3f"}]},
                {"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#6b9a76"}]},
                {"featureType":"road","elementType":"geometry","stylers":[{"color":"#38414e"}]},
                {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#212a37"}]},
                {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#9ca5b3"}]},
                {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#746855"}]},
                {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#1f2835"}]},
                {"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#f3d19c"}]},
                {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2f3948"}]},
                {"featureType":"transit.station","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},
                {"featureType":"water","elementType":"geometry","stylers":[{"color":"#17263c"}]},
                {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#515c6d"}]},
                {"featureType":"water","elementType":"labels.text.stroke","stylers":[{"color":"#17263c"}]}]
              ''');
            }
          },
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
        ),
      ),
    );
  }
}
