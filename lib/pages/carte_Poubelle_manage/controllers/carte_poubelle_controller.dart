import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:latlong2/latlong.dart' as latlong;

/// Contrôleur pour gérer l'état et les opérations de la carte des poubelles
class TrashMapController extends ChangeNotifier {
  final MapController mapController = MapController();
  final CustomInfoWindowController customInfoWindowController = CustomInfoWindowController();
  
  Position? currentPosition;
  bool isLoading = true;
  
  // Liste des poubelles
  List<TrashBin> trashBins = [];
  
  TrashMapController() {
    _initTrashBins();
    getCurrentLocation();
  }

  /// Initialise les données des poubelles
  void _initTrashBins() {
    trashBins = [
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
  }

  /// Récupère la localisation actuelle de l'utilisateur
  Future<void> getCurrentLocation() async {
    isLoading = true;
    notifyListeners();

    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si les services de localisation sont activés
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      isLoading = false;
      notifyListeners();
      return;
    }

    // Vérifier les permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        isLoading = false;
        notifyListeners();
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      isLoading = false;
      notifyListeners();
      return;
    }

    // Obtenir la position actuelle
    try {
      Position position = await Geolocator.getCurrentPosition();
      currentPosition = position;
      
      // Centre la carte sur la position actuelle
      /*
      if (mapController.camera.isValid) {
        mapController.move(
          latlong.LatLng(position.latitude, position.longitude),
          15.0,
        );
      }
      */
      
    } catch (e) {
      debugPrint("Erreur de géolocalisation: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Ajoute une nouvelle poubelle
  void addTrashBin(TrashBin bin) {
    trashBins.add(bin);
    notifyListeners();
  }

  /// Supprime une poubelle
  void removeTrashBin(String id) {
    trashBins.removeWhere((bin) => bin.id == id);
    notifyListeners();
  }

  /// Cache la fenêtre d'information
  void hideInfoWindow() {
    customInfoWindowController.hideInfoWindow!();
  }

  /// Affiche la fenêtre d'information pour un point donné
  /// 
  void showInfoWindow(Widget content, latlong.LatLng position) {
    // Note: Cette fonction nécessite une adaptation pour être compatible avec custom_info_window
    // qui attend un type LatLng de Google Maps
    try {
      //customInfoWindowController.addInfoWindow!(content, position);
    } catch (e) {
      debugPrint("Erreur lors de l'affichage de la fenêtre d'info: $e");
    }
  }

  /// Centre la carte sur une position donnée
  void centerOnPosition(latlong.LatLng position) {
    mapController.move(position, 15.0);
  }

  @override
  void dispose() {
    customInfoWindowController.dispose();
    super.dispose();
  }
}

/// Modèle de données pour une poubelle
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