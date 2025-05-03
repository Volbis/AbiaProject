import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlong;

// Enumération pour le statut des poubelles
enum Status {
  vide,
  normal,
  remplie,
  critique,
  horsService
}

class TrashBin {
  final String id;
  final String nomPoubelle;
  final latlong.LatLng latLng;
  final String address;
  final Status status;
  final double fillPercentage;
  final double capaciteTotale;
  final double seuilAlerte;
  final bool verrouille;
  final String binColor; // blue, green, orange, grey

  TrashBin({
    required this.id,
    required this.nomPoubelle,
    required this.latLng,
    required this.address,
    required this.status,
    required this.fillPercentage,
    required this.capaciteTotale,
    required this.seuilAlerte,
    required this.verrouille,
    required this.binColor,
  });
}

class Collection {
  final String id;
  final String binType;
  final String binColor;
  final String truckName;
  final DateTime collectionTime;
  final TrashBin? trashBin; // Référence à la poubelle associée à cette collecte
  final double quantiteCollectee; // Quantité de déchets collectés

  Collection({
    required this.id,
    required this.binType,
    required this.binColor,
    required this.truckName,
    required this.collectionTime,
    this.trashBin,
    this.quantiteCollectee = 0.0,
  });
}

class CollecteController extends GetxController {
  // Observable list for collection history
  final RxList<Collection> collections = <Collection>[].obs;
  final RxList<TrashBin> trashBins = <TrashBin>[].obs;
  final RxBool isLoading = true.obs;
  
  // Pour filtrer les collectes par jour/semaine/mois/année (fonctionnalité supplémentaire)
  final Rx<String> filterType = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTrashBins();
    fetchCollections();
  }

  // Récupérer les poubelles
  Future<void> fetchTrashBins() async {
    try {
      // Simulation d'une récupération de poubelles à partir d'une API
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Données d'exemple
      trashBins.value = [
        TrashBin(
          id: 'CD453',
          nomPoubelle: 'Poubelle Alpha',
          latLng: latlong.LatLng(48.8566, 2.3522), // Paris
          address: '15 Rue de la Paix, Paris',
          status: Status.normal,
          fillPercentage: 45.0,
          capaciteTotale: 100.0,
          seuilAlerte: 80.0,
          verrouille: true,
          binColor: 'blue',
        ),
        TrashBin(
          id: 'DC254',
          nomPoubelle: 'Poubelle Beta',
          latLng: latlong.LatLng(48.8584, 2.3505), // Paris proche
          address: '8 Avenue de l\'Opéra, Paris',
          status: Status.remplie,
          fillPercentage: 78.0,
          capaciteTotale: 120.0,
          seuilAlerte: 90.0,
          verrouille: false,
          binColor: 'green',
        ),
        TrashBin(
          id: 'DV435',
          nomPoubelle: 'Poubelle Sigma',
          latLng: latlong.LatLng(48.8738, 2.3749), // Paris autre quartier
          address: '25 Rue du Faubourg du Temple, Paris',
          status: Status.critique,
          fillPercentage: 95.0,
          capaciteTotale: 150.0,
          seuilAlerte: 85.0,
          verrouille: true,
          binColor: 'orange',
        ),
        TrashBin(
          id: 'AG346',
          nomPoubelle: 'Poubelle Gama',
          latLng: latlong.LatLng(48.8600, 2.3400), // Paris autre zone
          address: '12 Rue de Rivoli, Paris',
          status: Status.vide,
          fillPercentage: 10.0,
          capaciteTotale: 100.0,
          seuilAlerte: 80.0,
          verrouille: true,
          binColor: 'blue',
        ),
        TrashBin(
          id: 'AK117',
          nomPoubelle: 'Poubelle Delta',
          latLng: latlong.LatLng(48.8500, 2.3400), // Paris sud
          address: '45 Boulevard Saint-Germain, Paris',
          status: Status.horsService,
          fillPercentage: 0.0,
          capaciteTotale: 120.0,
          seuilAlerte: 90.0,
          verrouille: false,
          binColor: 'grey',
        ),
      ];
    } catch (e) {
      debugPrint('Error fetching trash bins: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de récupérer les poubelles',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Fetch collection history
  Future<void> fetchCollections() async {
    isLoading.value = true;
    
    try {
      // Simulate API call with a delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data to match the UI in the image
      collections.value = [
        Collection(
          id: 'COL-001',
          binType: 'Poubelle',
          binColor: 'blue',
          truckName: 'Truck Alpha',
          collectionTime: DateTime.now().subtract(const Duration(minutes: 5)),
          trashBin: trashBins.isNotEmpty ? trashBins[0] : null,
          quantiteCollectee: 45.0,
        ),
        Collection(
          id: 'COL-002',
          binType: 'Poubelle',
          binColor: 'green',
          truckName: 'Truck Beta',
          collectionTime: DateTime.now().subtract(const Duration(minutes: 34)),
          trashBin: trashBins.length > 1 ? trashBins[1] : null,
          quantiteCollectee: 78.0,
        ),
        Collection(
          id: 'COL-003',
          binType: 'Poubelle',
          binColor: 'orange',
          truckName: 'Truck Sigma',
          collectionTime: DateTime.now().subtract(const Duration(hours: 4)),
          trashBin: trashBins.length > 2 ? trashBins[2] : null,
          quantiteCollectee: 95.0,
        ),
        Collection(
          id: 'COL-004',
          binType: 'Poubelle',
          binColor: 'blue',
          truckName: 'Truck Gama',
          collectionTime: DateTime.now().subtract(const Duration(hours: 12)),
          trashBin: trashBins.length > 3 ? trashBins[3] : null,
          quantiteCollectee: 10.0,
        ),
        Collection(
          id: 'COL-005',
          binType: 'Poubelle',
          binColor: 'grey',
          truckName: 'Truck Delta',
          collectionTime: DateTime.now().subtract(const Duration(hours: 15)),
          trashBin: trashBins.length > 4 ? trashBins[4] : null,
          quantiteCollectee: 0.0,
        ),
        Collection(
          id: 'COL-006',
          binType: 'Poubelle',
          binColor: 'orange',
          truckName: 'Truck Sigma',
          collectionTime: DateTime.now().subtract(const Duration(days: 1)),
          trashBin: trashBins.length > 2 ? trashBins[2] : null,
          quantiteCollectee: 85.0,
        ),
      ];
    } catch (e) {
      // Handle errors
      debugPrint('Error fetching collections: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de récupérer l\'historique des collectes',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Format time difference
  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} j';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} h';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} min';
    } else {
      return 'À l\'instant';
    }
  }
  
  // Filtrer les collectes selon une période
  void setFilter(String type) {
    filterType.value = type;
    fetchFilteredCollections();
  }
  
  // Récupérer les collectes filtrées
  Future<void> fetchFilteredCollections() async {
    isLoading.value = true;
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Dans une application réelle, vous feriez un appel API avec le filtre
      // Ici, nous simulons juste un filtrage sur les données existantes
      final DateTime now = DateTime.now();
      final List<Collection> allCollections = [
        Collection(
          id: 'COL-001',
          binType: 'Poubelle',
          binColor: 'blue',
          truckName: 'Truck Alpha',
          collectionTime: now.subtract(const Duration(minutes: 5)),
          trashBin: trashBins.isNotEmpty ? trashBins[0] : null,
          quantiteCollectee: 45.0,
        ),
        Collection(
          id: 'COL-002',
          binType: 'Poubelle',
          binColor: 'green',
          truckName: 'Truck Beta',
          collectionTime: now.subtract(const Duration(minutes: 34)),
          trashBin: trashBins.length > 1 ? trashBins[1] : null,
          quantiteCollectee: 78.0,
        ),
        Collection(
          id: 'COL-003',
          binType: 'Poubelle',
          binColor: 'orange',
          truckName: 'Truck Sigma',
          collectionTime: now.subtract(const Duration(hours: 4)),
          trashBin: trashBins.length > 2 ? trashBins[2] : null,
          quantiteCollectee: 95.0,
        ),
        Collection(
          id: 'COL-004',
          binType: 'Poubelle',
          binColor: 'blue',
          truckName: 'Truck Gama',
          collectionTime: now.subtract(const Duration(hours: 12)),
          trashBin: trashBins.length > 3 ? trashBins[3] : null,
          quantiteCollectee: 10.0,
        ),
        Collection(
          id: 'COL-005',
          binType: 'Poubelle',
          binColor: 'grey',
          truckName: 'Truck Delta',
          collectionTime: now.subtract(const Duration(hours: 15)),
          trashBin: trashBins.length > 4 ? trashBins[4] : null,
          quantiteCollectee: 0.0,
        ),
        Collection(
          id: 'COL-006',
          binType: 'Poubelle',
          binColor: 'orange',
          truckName: 'Truck Sigma',
          collectionTime: now.subtract(const Duration(days: 1)),
          trashBin: trashBins.length > 2 ? trashBins[2] : null,
          quantiteCollectee: 85.0,
        ),
        Collection(
          id: 'COL-007',
          binType: 'Poubelle',
          binColor: 'green',
          truckName: 'Truck Omega',
          collectionTime: now.subtract(const Duration(days: 3)),
          trashBin: trashBins.length > 1 ? trashBins[1] : null,
          quantiteCollectee: 65.0,
        ),
        Collection(
          id: 'COL-008',
          binType: 'Poubelle',
          binColor: 'blue',
          truckName: 'Truck Zeta',
          collectionTime: now.subtract(const Duration(days: 7)),
          trashBin: trashBins.isNotEmpty ? trashBins[0] : null,
          quantiteCollectee: 90.0,
        ),
      ];
      
      switch (filterType.value) {
        case 'today':
          collections.value = allCollections.where((c) => 
            c.collectionTime.day == now.day && 
            c.collectionTime.month == now.month && 
            c.collectionTime.year == now.year
          ).toList();
          break;
        case 'week':
          final weekAgo = now.subtract(const Duration(days: 7));
          collections.value = allCollections.where((c) => 
            c.collectionTime.isAfter(weekAgo)
          ).toList();
          break;
        case 'month':
          collections.value = allCollections.where((c) => 
            c.collectionTime.month == now.month && 
            c.collectionTime.year == now.year
          ).toList();
          break;
        default:
          collections.value = allCollections;
      }
    } catch (e) {
      debugPrint('Error filtering collections: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Fonction pour obtenir les détails d'une collection spécifique
  Collection? getCollectionDetails(String id) {
    try {
      return collections.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Fonction pour obtenir une poubelle spécifique par ID
  TrashBin? getTrashBin(String id) {
    try {
      return trashBins.firstWhere((bin) => bin.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Fonction pour obtenir la couleur correcte à partir du statut
  Color getStatusColor(Status status) {
    switch (status) {
      case Status.vide:
        return Colors.green;
      case Status.normal:
        return Colors.blue;
      case Status.remplie:
        return Colors.orange;
      case Status.critique:
        return Colors.red;
      case Status.horsService:
        return Colors.grey;
    }
  }
  
  // Fonction pour obtenir le texte du statut
  String getStatusText(Status status) {
    switch (status) {
      case Status.vide:
        return 'Vide';
      case Status.normal:
        return 'Normal';
      case Status.remplie:
        return 'Remplie';
      case Status.critique:
        return 'Critique';
      case Status.horsService:
        return 'Hors Service';
    }
  }
}