import 'package:abiaproject/common/theme/app_theme.dart';
import 'package:abiaproject/pages/carte_Poubelle_manage/controllers/carte_poubelle_controller.dart';
import 'package:abiaproject/partagés/widgets_partagés/nav_bar_avec_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class TrashMapScreen extends StatefulWidget {
  final TrashMapController trashMapController;
  
  const TrashMapScreen({Key? key, required this.trashMapController}) : super(key: key);

  @override
  State<TrashMapScreen> createState() => _TrashMapScreenState();
}

class _TrashMapScreenState extends State<TrashMapScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  bool _loading = true;
  
  // Variables pour l'infobulle personnalisée
  TrashBin? selectedBin;
  bool showInfoWindow = false;

  // Utiliser latlong.LatLng pour la latitude et la longitude
  // Liste des poubelles 
  final List<TrashBin> trashBins = [
    TrashBin(
      id: '1',
      latLng: latlong.LatLng(48.8566, 2.3522),
      type: 'Recyclables',
      address: 'Rue Victor Brault',
    ),
    TrashBin(
      id: '2',
      latLng: latlong.LatLng(48.8570, 2.3510), 
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

  // Remplacez tout le contenu de votre méthode build avec ce qui suit:
  @override
  Widget build(BuildContext context) {
    // Utilisez un Scaffold comme conteneur principal
    return Scaffold(
      // Le corps contient la carte et tous les éléments superposés
      body: Stack(
        children: [
          // La carte en arrière-plan (couvre tout l'écran)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition != null
                  ? latlong.LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : latlong.LatLng(48.8566, 2.3522),
              initialZoom: 18,
              onTap: (tapPosition, point) {
                setState(() {
                  showInfoWindow = false;
                });
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
                    color: AppColors.primaryColor,
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
                        setState(() {
                          selectedBin = bin;
                          showInfoWindow = true;
                        });
                      },
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.primaryColor,
                        size: 30,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          
          // Titre flottant en haut
          Positioned(
            top: 40, // Ajusté pour la zone safe area
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 290,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: const Text(
                  'Carte des poubelles',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 83, 83, 83),
                  ),
                ),
              ),
            ),
          ),
          
          // Infobulle personnalisée
          if (showInfoWindow && selectedBin != null)
            Positioned(
              bottom: 130, // Ajusté pour être au-dessus de la barre de navigation
              left: 20,
              right: 20,
              child: _buildTrashBinInfoWindow(selectedBin!),
            ),
          
          // Bouton d'action flottant
          Positioned(
            bottom: 100, // Ajusté pour être au-dessus de la barre de navigation
            right: 20,
            child: SizedBox(
              width: 60,
              height: 60,
              child: Material(
                color: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    if (_currentPosition != null) {
                      _mapController.move(
                        latlong.LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                        18,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: const Center(
                    child: Icon(
                      Icons.my_location_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // NavBar flottante en bas (par-dessus tout)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: NavBarAvecPlus(
              initialPage: 1, // Icône de carte sélectionnée
              onPageChanged: (index) {
                // Logique de navigation entre les différentes pages
                switch (index) {
                  case 0:
                    Navigator.pushReplacementNamed(context, '/home');
                    break;
                  case 1:
                    // Déjà sur cette page
                    break;
                  case 3:
                    Navigator.pushReplacementNamed(context, '/messages');
                    break;
                  case 4:
                    Navigator.pushReplacementNamed(context, '/profile');
                    break;
                }
              },
              onPlusButtonPressed: () {
                // Action pour le bouton + (ajouter une nouvelle poubelle)
                print("Ajouter une nouvelle poubelle");
              },
              useSvgIcons: false, // Set this to true to use SVG icons
              icons: const [
                Symbols.distance_rounded,
                Icons.bar_chart_rounded,
                Icons.add,
                Symbols.delivery_truck_bolt_rounded,
                Symbols.notifications_unread_rounded,
              ],
              colors: const [
                AppColors.primaryColor,
                AppColors.primaryColor,
                AppColors.primaryColor,
                AppColors.primaryColor,
                AppColors.primaryColor,
              ],
            ),
          ),
        ],
      ),
    );
  }


  /// Construit la fenêtre d'information pour une poubelle
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
                  onPressed: () {
                    // Action pour voir les détails
                  },
                  child: const Text('Détails'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      showInfoWindow = false;
                    });
                  },
                  child: const Text('Fermer'),
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
  final latlong.LatLng latLng; 
  final String type;
  final String address;

  TrashBin({
    required this.id,
    required this.latLng,
    required this.type,
    required this.address,
  });
}