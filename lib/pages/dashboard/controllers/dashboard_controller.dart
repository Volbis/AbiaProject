import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:get/get.dart'; 
import '../../../database/login_data_base.dart';

class DashboardController extends GetxController {
  // Variables réactives pour les données des graphiques
  RxDouble averageFillRate = 0.0.obs;
  RxList<double> binsByDay = <double>[0, 0, 0, 0, 0, 0, 0].obs;
  
  // Jours de la semaine pour les labels du graphique à barres
  final List<String> weekDays = ['Sam', 'Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven'];
  
  // État de chargement
  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllDashboardData();
  }

  // Méthode principale pour récupérer toutes les données du tableau de bord
  Future<void> fetchAllDashboardData() async {
    isLoading.value = true;
    hasError.value = false;
    
    try {
      // Exécuter les deux requêtes en parallèle
      await Future.wait([
        updateFillRateData(),
        updateBinsByDayData(),
      ]);
      
      if (kDebugMode) {
        print('Toutes les données du tableau de bord récupérées avec succès');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Erreur lors de la récupération des données: $e';
      if (kDebugMode) {
        print(errorMessage.value);
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Méthode pour mettre à jour le taux de remplissage moyen
  Future<void> updateFillRateData() async {
    try {
      // Appel à la procédure stockée qui calcule le taux moyen de remplissage
      final results = await DatabaseConnection.executeQuery(
        'SELECT AVG(niveau_remplissage) AS moyenne FROM poubelle WHERE verouille = 0'
      );
      
      if (results.isNotEmpty) {
        final row = results.first;
        // La moyenne pourrait être null si aucune poubelle n'est enregistrée
        final moyenne = row['moyenne'] as double?;
        averageFillRate.value = moyenne ?? 0.0;
        
        if (kDebugMode) {
          print('Taux de remplissage moyen mis à jour: ${averageFillRate.value}%');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la mise à jour du taux de remplissage: $e');
      }
      throw e;
    }
  }

  // Méthode pour mettre à jour les données sur le nombre de poubelles pleines par jour
  Future<void> updateBinsByDayData() async {
    try {
      // Appel à la procédure stockée qui compte les poubelles pleines par jour
      // Supposons qu'une poubelle est "pleine" si son niveau de remplissage est > 80%
      final results = await DatabaseConnection.executeQuery('''
        SELECT 
          DAYOFWEEK(date_derniere_mis_a_jour) AS jour_semaine, 
          COUNT(*) AS nombre_poubelles 
        FROM poubelle
        WHERE niveau_remplissage > 90 AND actif = 1
        GROUP BY DAYOFWEEK(date_derniere_mis_a_jour)
        ORDER BY jour_semaine
      ''');
      
      // Réinitialiser le tableau (tous les jours à 0)
      List<double> newData = List.filled(7, 0.0);
      
      // Remplir avec les données de la base
      for (var row in results) {
        // MySQL DAYOFWEEK: 1=Dimanche, 2=Lundi, ..., 7=Samedi
        // Notre tableau: 0=Samedi, 1=Dimanche, ..., 6=Vendredi
        int jourIndex = (row['jour_semaine'] as int) % 7; // 1→1, 2→2, ..., 7→0
        if (jourIndex == 0) jourIndex = 7; // Correction pour samedi
        jourIndex = (jourIndex + 5) % 7; // Alignement avec notre array
        
        // Mettre à jour le nombre de poubelles pour ce jour
        newData[jourIndex] = (row['nombre_poubelles'] as int).toDouble();
      }
      
      // Mettre à jour la liste observable
      binsByDay.value = newData;
      
      if (kDebugMode) {
        print('Données des poubelles par jour mises à jour: $newData');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la mise à jour des données par jour: $e');
      }
      throw e;
    }
  }

  // Calcul du pourcentage de poubelles vides pour le graphique circulaire
  double getEmptyFillRate() {
    return 100 - averageFillRate.value;
  }

  // Obtenir la valeur maximale pour l'axe Y du graphique à barres
  double getMaxBinCount() {
    if (binsByDay.isEmpty) return 100; // Valeur par défaut si vide
    return binsByDay.reduce((curr, next) => curr > next ? curr : next);
  }

  // Méthode pour obtenir le jour avec le plus de poubelles pleines
  String getMostCriticalDay() {
    if (binsByDay.every((element) => element == 0)) {
      return 'Aucun'; // Cas où toutes les valeurs sont à 0
    }
    
    int maxIndex = 0;
    double maxValue = 0;
    
    for (int i = 0; i < binsByDay.length; i++) {
      if (binsByDay[i] > maxValue) {
        maxValue = binsByDay[i];
        maxIndex = i;
      }
    }
    
    return weekDays[maxIndex];
  }

  // Méthode pour rafraîchir toutes les données
    Future<void> refreshDashboard() async {
      return fetchAllDashboardData();
    } //Pas encore implémenté dans le contrôleleur
  }