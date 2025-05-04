import 'package:flutter/foundation.dart';

class DashboardController {
  // Données pour le graphique à secteurs (taux de remplissage)
  final double averageFillRate = 12.0; // Pourcentage moyen de remplissage

  // Données pour le graphique à barres (nombre de poubelles pleines par jour)
  final List<double> binsByDay = [200, 120, 50, 20, 150, 200, 130];
  
  // Jours de la semaine pour les labels du graphique à barres
  final List<String> weekDays = ['Sam', 'Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven'];

  // Méthode pour récupérer les données des capteurs (simulation)
  Future<void> fetchSensorData() async {
    // Ici vous pourriez implémenter une requête API pour obtenir
    // des données réelles depuis vos capteurs de poubelles
    try {
      // Simulation d'une requête réseau
      await Future.delayed(const Duration(seconds: 1));
      
      // Logique de mise à jour des données
      if (kDebugMode) {
        print('Données du capteur récupérées avec succès');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération des données: $e');
      }
    }
  }

  // Calcul du pourcentage total pour le graphique circulaire
  double getEmptyFillRate() {
    return 100 - averageFillRate;
  }

  // Obtenir la valeur maximale pour l'axe Y du graphique à barres
  double getMaxBinCount() {
    return binsByDay.reduce((curr, next) => curr > next ? curr : next);
  }

  // Méthode pour obtenir le jour avec le plus de poubelles pleines
  String getMostCriticalDay() {
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
}