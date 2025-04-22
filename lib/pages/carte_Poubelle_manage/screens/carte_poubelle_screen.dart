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
      niveauDeRemplissage: NiveauDeRemplissage.full,
    ),
    TrashBin(
      id: '2',
      latLng: latlong.LatLng(48.8570, 2.3510), 
      type: 'Ordures ménagères',
      address: 'Rue Wilson',
      niveauDeRemplissage: NiveauDeRemplissage.medium,
    ),
  ];

  // Couleur de remplissage en fonction du niveau
  Color _getFillLevelColor(NiveauDeRemplissage? level) {
    // Gestion du cas où level est null
    if (level == null) {
      return Colors.grey; // Couleur par défaut si null
    }
    
    switch (level) {
      case NiveauDeRemplissage.empty:
        return Colors.green;
      case NiveauDeRemplissage.medium:
        return Colors.amber;
      case NiveauDeRemplissage.full:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // De même pour la méthode _getFillLevelText
  String _getFillLevelText(NiveauDeRemplissage? level) {
    // Gestion du cas où level est null
    if (level == null) {
      return "Inconnu"; // Texte par défaut si null
    }
    
    switch (level) {
      case NiveauDeRemplissage.empty:
        return "Vide";
      case NiveauDeRemplissage.medium:
        return "À moitié pleine";
      case NiveauDeRemplissage.full:
        return "Pleine";
      default:
        return "Inconnu";
    }
  }
      
    
    //Mettre à jour future du niveau de remplissage
  void updateTrashBinFillLevel(String binId, double fillPercentage) {
    setState(() {
      final index = trashBins.indexWhere((bin) => bin.id == binId);
      if (index != -1) {
        // Remplacez cette poubelle par une nouvelle avec le niveau mis à jour
        NiveauDeRemplissage newLevel = _calculateFillLevel(fillPercentage);
        
        // Dans une implémentation réelle, vous mettriez à jour l'objet TrashBin lui-même
        // Pour l'instant, nous recréons l'objet entier
        TrashBin updatedBin = TrashBin(
          id: trashBins[index].id,
          latLng: trashBins[index].latLng,
          type: trashBins[index].type,
          address: trashBins[index].address,
          niveauDeRemplissage: newLevel,
        );
        
        // Mettre à jour la liste
        trashBins[index] = updatedBin;
        
        // Si la poubelle est actuellement sélectionnée, mettre à jour également selectedBin
        if (selectedBin?.id == binId) {
          selectedBin = updatedBin;
        }
      }
    });
  }

  NiveauDeRemplissage _calculateFillLevel(double fillPercentage) {
    if (fillPercentage < 30) {
      return NiveauDeRemplissage.empty;
    } else if (fillPercentage < 70) {
      return NiveauDeRemplissage.medium;
    } else {
      return NiveauDeRemplissage.full;
    }
  }

  // Initialisation de l'état
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
                tileProvider: NetworkTileProvider(),
                retinaMode: true, 
              ),
              
              // Marqueur de localisation actuelle
              CurrentLocationLayer(
                style: const LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    color: AppColors.primaryColor,
                    child: Icon(
                      Icons.person_pin,
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
            StreamBuilder(
              stream: Stream.periodic(const Duration(milliseconds: 100)),
              builder: (context, _) {
                // Vérification supplémentaire pour s'assurer que selectedBin reste non-null
                // pendant toute la durée du Stream
                if (selectedBin == null) return const SizedBox.shrink();
                
                // Copie locale sécurisée pour éviter les changements pendant l'exécution
                final localSelectedBin = selectedBin!;
                
                // Conversion des coordonnées géographiques en coordonnées d'écran
                final pxPoint = _mapController.camera.latLngToScreenPoint(localSelectedBin.latLng);
                
                if (pxPoint == null) return const SizedBox.shrink();
                
                // Calcul des décalages pour positionner l'infobulle au-dessus du marqueur
                final infoWindowWidth = 340.0;
                final infoWindowHeight = 200.0;
                final markerHeight = 35.0; // Hauteur estimée du marqueur
                
                // Position de l'infobulle (centrée horizontalement, au-dessus du marqueur)
                return Positioned(
                  left: pxPoint.x - (infoWindowWidth / 2),
                  top: pxPoint.y - infoWindowHeight - markerHeight,
                  width: infoWindowWidth,
                  child: _buildTrashBinInfoWindow(localSelectedBin),
                );
              },
            ),  

          // Bouton d'action flottant
          Positioned(
            bottom: 120, // Ajusté pour être au-dessus de la barre de navigation
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
              initialPage: 0, // Icône de carte sélectionnée
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
      color: const Color.fromARGB(230, 238, 230, 255), // Couleur de fond violette claire
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // En-tête avec icône et texte
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFFE1D5FF), // Couleur légèrement plus foncée pour l'en-tête
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              // Icône dans un cercle
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor, // Couleur violette plus foncée
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Titre de l'infobulle
              Text(
                bin.type,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.secondaryColor, // Texte violet foncé
                ),
              ),
            ],
          ),
        ),
        // Corps de l'infobulle
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // status de la poubelle
              Row(
                children: [
                  const Text(
                    "Statut : ",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A6A6A),
                    ),
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                    shape: BoxShape.circle,
                      color: _getFillLevelColor(bin.niveauDeRemplissage),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getFillLevelText(bin.niveauDeRemplissage),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getFillLevelColor(bin.niveauDeRemplissage),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              // Message principal
              Text(
                bin.address,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 48, 48, 48),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Informations supplémentaires sur cette poubelle.",
                style: TextStyle(
                  fontSize: 14, 
                  
                  color: Color(0xFF6A6A6A),
                ),
              ),
              const SizedBox(height: 20), // Espace supplémentaire
              
              // Boutons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
  
                    onPressed: () {
                      setState(() {
                        showInfoWindow = false;
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Fermer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      
      ],
    ),
  );
}

}

// Niveau de remplissage de la poubelle
enum NiveauDeRemplissage { empty, medium, full }

class TrashBin {
  final String id;
  final latlong.LatLng latLng; 
  final String type;
  final String address;
  final NiveauDeRemplissage niveauDeRemplissage; // Niveau de remplissage de la poubelle

  TrashBin({
    required this.id,
    required this.latLng,
    required this.type,
    required this.address,
    required this.niveauDeRemplissage, 
  });
}