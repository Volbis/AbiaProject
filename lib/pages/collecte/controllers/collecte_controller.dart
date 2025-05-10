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

  // Ajoute une nouvelle collecte à l'historique et l'enregistre en base de données
  Future<bool> ajouterNouvelleCollecte({
    required String binId,
    required String binType,
    required String binColor,
    required String truckName,
    required double quantite,
    String? binName,
    String? binAddress,
    double? binCapacite,
  }) async {
    isLoading.value = true;
    
    try {
      // Créer l'objet TrashBin si les informations sont fournies
      TrashBin? trashBin;
      if (binName != null && binAddress != null && binCapacite != null) {
        trashBin = TrashBin(
          nomPoubelle: binName,
          address: binAddress,
          capaciteTotale: binCapacite,
        );
      }
      
      // Générer un ID unique basé sur un timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final id = 'COL-${timestamp.toString().substring(timestamp.toString().length - 4)}';
      
      // Créer l'objet Collection
      final nouvelleCollecte = Collection(
        id: id,
        binType: binType,
        binColor: binColor,
        truckName: truckName,
        collectionTime: DateTime.now(),
        quantiteCollectee: quantite,
        trashBin: trashBin,
      );
      
      // En production: Envoyer les données à l'API ou à la base de données
      // await DatabaseConnection.executeQuery(
      //   'INSERT INTO collectes (id, bin_type, bin_color, truck_name, collection_time, quantite) '
      //   'VALUES (?, ?, ?, ?, ?, ?)',
      //   [id, binType, binColor, truckName, DateTime.now().toIso8601String(), quantite]
      // );
      
      // Ajouter la nouvelle collecte à la liste en mémoire (au début pour qu'elle apparaisse en haut)
      collections.insert(0, nouvelleCollecte);
      
      if (kDebugMode) {
        print("Nouvelle collecte ajoutée: $id");
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors de l'ajout de la collecte: $e");
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Récupère toutes les collectes depuis la base de données
  Future<void> fetchCollections() async {
    isLoading.value = true;
    
    try {
      // En production: Récupérer les données depuis l'API ou la base de données
      // final results = await DatabaseConnection.executeQuery(
      //   'SELECT * FROM collectes ORDER BY collection_time DESC'
      // );
      
      // Pour l'instant, on utilise les données de test
      collections.clear();
      collections.addAll(_generateTestData());
      
      if (kDebugMode) {
        print("Collectes récupérées: ${collections.length}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors de la récupération des collectes: $e");
      }
    } finally {
      isLoading.value = false;
    }
  }

}