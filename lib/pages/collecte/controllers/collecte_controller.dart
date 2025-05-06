import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class TrashBin {
  final String nomPoubelle;
  final String address;
  final double capaciteTotale;

  TrashBin({
    required this.nomPoubelle,
    required this.address,
    required this.capaciteTotale,
  });
}

class Collection {
  final String id;
  final String binType;
  final String binColor;
  final String truckName;
  final DateTime collectionTime;
  final double quantiteCollectee;
  final TrashBin? trashBin;

  Collection({
    required this.id,
    required this.binType,
    required this.binColor,
    required this.truckName,
    required this.collectionTime,
    required this.quantiteCollectee,
    this.trashBin,
  });
}

class CollecteController extends GetxController {
  // Données statiques directement dans les variables observables
  final RxBool isLoading = false.obs; 
  final RxList<Collection> collections = <Collection>[].obs;

  // Constructeur avec initialisation immédiate des données
  CollecteController() {
    // Pré-remplir avec les données statiques
    collections.addAll(_generateTestData());
    if (kDebugMode) {
      print("Contrôleur initialisé avec ${collections.length} collectes");
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Pas besoin d'appeler fetchCollections() car les données sont déjà chargées
    if (kDebugMode) {
      print("onInit appelé, collections: ${collections.length}");
    }
  }

  // Génère des données de test pour l'historique des collectes
  List<Collection> _generateTestData() {
    final data = [
      Collection(
        id: 'COL-1234',
        binType: 'Poubelle',
        binColor: 'blue',
        truckName: 'Camion A-001',
        collectionTime: DateTime.now().subtract(const Duration(hours: 5)),
        quantiteCollectee: 18.5,
        trashBin: TrashBin(
          nomPoubelle: 'P-Marché Central',
          address: 'Avenue du Marché, Quartier Centre',
          capaciteTotale: 120.0,
        ),
      ),
      Collection(
        id: 'COL-1235',
        binType: 'Bac',
        binColor: 'green',
        truckName: 'Camion B-002',
        collectionTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        quantiteCollectee: 45.2,
        trashBin: TrashBin(
          nomPoubelle: 'B-Hôpital Général',
          address: 'Rue Santé, Zone Médicale',
          capaciteTotale: 240.0,
        ),
      ),
      Collection(
        id: 'COL-1236',
        binType: 'Conteneur',
        binColor: 'grey',
        truckName: 'Camion A-003',
        collectionTime: DateTime.now().subtract(const Duration(days: 2)),
        quantiteCollectee: 120.0,
        trashBin: TrashBin(
          nomPoubelle: 'C-Zone Industrielle',
          address: 'Boulevard Industriel, Secteur Est',
          capaciteTotale: 500.0,
        ),
      ),
      Collection(
        id: 'COL-1237',
        binType: 'Poubelle',
        binColor: 'orange',
        truckName: 'Camion C-001',
        collectionTime: DateTime.now().subtract(const Duration(days: 3, hours: 8)),
        quantiteCollectee: 22.7,
        trashBin: TrashBin(
          nomPoubelle: 'P-École Primaire',
          address: 'Rue de l\'Éducation, Quartier Sud',
          capaciteTotale: 120.0,
        ),
      ),
    ];
    
    if (kDebugMode) {
      print("Données de test générées: ${data.length} collectes");
    }
    
    return data;
  }

  // Convertit un DateTime en texte "il y a X temps"
  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'à l\'instant';
    }
  }
}