import 'package:abiaproject/pages/carte_Poubelle_manage/controllers/carte_poubelle_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:location/location.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:geolocator/geolocator.dart';

class TrashMapScreen extends StatefulWidget {
  const TrashMapScreen({Key? key, required TrashMapController trashMapController}) : super(key: key);

  @override
  State<TrashMapScreen> createState() => _TrashMapScreenState();
}

class _TrashMapScreenState extends State<TrashMapScreen> {
  final MapController _mapController = MapController();
  final CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();
  Position? _currentPosition;
  bool _loading = true;

  // Utiliser latlong.LatLng au lieu de LatLng
  final List<TrashBin> trashBins = [
    TrashBin(
      id: '1',
      latLng: latlong.LatLng(48.8566, 2.3522), // Utilisez latlong.LatLng
      type: 'Recyclables',
      address: 'Rue Victor Brault',
    ),
    TrashBin(
      id: '2',
      latLng: latlong.LatLng(48.8570, 2.3510), // Utilisez latlong.LatLng
      type: 'Ordures ménagères',
      address: 'Rue Wilson',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si les services de localisation sont activés
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _loading = false);
      return;
    }

    // Vérifier les permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _loading = false);
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      setState(() => _loading = false);
      return;
    }

    // Obtenir la position actuelle
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Titre de la page
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              child: const Text(
                'Carte des poubelles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Carte principale
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentPosition != null
                          ? latlong.LatLng(_currentPosition!.latitude, _currentPosition!.longitude) // Utilisez latlong.LatLng
                          : latlong.LatLng(48.8566, 2.3522), // Utilisez latlong.LatLng
                      initialZoom: 15,
                      onTap: (tapPosition, point) {
                        _customInfoWindowController.hideInfoWindow!();
                      },
                    ),
                    children: [
                      // La couche de la carte OpenStreetMap
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      
                      // Marqueur de localisation actuelle
                      CurrentLocationLayer(
                        style: const LocationMarkerStyle(
                          marker: DefaultLocationMarker(
                            color: Colors.blue,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                          accuracyCircleColor: Colors.blue,
                        ),
                      ),
                      
                      // Marqueurs des poubelles
                      MarkerLayer(
                        markers: trashBins.map((bin) {
                          return Marker(
                            width: 40,
                            height: 40,
                            point: bin.latLng,
                            child: GestureDetector(
                              onTap: () {
                                // Si vous avez une erreur ici, assurez-vous que custom_info_window 
                                // est compatible avec latlong2.LatLng ou convertissez les coordonnées
                                _customInfoWindowController.addInfoWindow!(
                                  _buildTrashBinInfoWindow(bin),
                                  bin.latLng as LatLng,
                                );
                              },
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.green,
                                size: 30,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  
                  // Fenêtre d'information pour les poubelles
                  CustomInfoWindow(
                    controller: _customInfoWindowController,
                    height: 100,
                    width: 200,
                    offset: 35,
                  ),
                  
                  // Bouton d'action flottant
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        // Action pour ajouter une nouvelle poubelle
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Barre de navigation inférieure
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavBarItem(Icons.person_outline, true),
                  _buildNavBarItem(Icons.grid_view, false),
                  const SizedBox(width: 60), // Espace pour le bouton d'action
                  _buildNavBarItem(Icons.message_outlined, false),
                  _buildNavBarItem(Icons.notifications_outlined, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, bool isSelected) {
    return Icon(
      icon,
      size: 25,
      color: isSelected ? Colors.blue : Colors.grey,
    );
  }

  Widget _buildTrashBinInfoWindow(TrashBin bin) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bin.type,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(bin.address),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text('Détails'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TrashBin {
  final String id;
  final latlong.LatLng latLng; // Utilisez latlong.LatLng ici
  final String type;
  final String address;

  TrashBin({
    required this.id,
    required this.latLng,
    required this.type,
    required this.address,
  });
}