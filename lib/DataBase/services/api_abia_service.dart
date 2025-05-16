import 'dart:convert';
import 'package:http/http.dart' as http;

class AbiaApiService {
  final String baseUrl = 'http://10.0.2.2/api-abia.php';
  
  /// Récupère les niveaux de remplissage de toutes les poubelles
  Future<Map<String, PoubelleInfo>> getFillLevelsFromApi() async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'get_fill_levels'}),
      );
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        if (jsonData['success'] == true && jsonData.containsKey('levels')) {
          final Map<String, dynamic> levelsData = jsonData['levels'];
          final Map<String, PoubelleInfo> result = {};
          
          levelsData.forEach((id, data) {
            result[id] = PoubelleInfo.fromJson(data);
          });
          
          return result;
        } else {
          throw Exception('Erreur dans la réponse API: ${jsonData['error'] ?? 'Format de réponse incorrect'}');
        }
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de communication avec l\'API: $e');
    }
  }

  /*
  Fait directement par l'appel d'api par le système arduino
  /// Met à jour les informations d'une poubelle
  Future<bool> updatePoubelle({
    required String id,
    required int remplissage,
    required String etat,
    required double latitude,
    required double longitude,
    bool alerte = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id,
          'remplissage': remplissage,
          'etat': etat,
          'latitude': latitude,
          'longitude': longitude,
          'alerte': alerte,
        }),
      );
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['success'] == true;
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de communication avec l\'API: $e');
    }
  }
  */
}

/// Classe représentant les informations d'une poubelle
class PoubelleInfo {
  final String id;
  final double niveauRemplissage;
  final String statut;
  final double latitude;
  final double longitude;
  
  PoubelleInfo({
    required this.id,
    required this.niveauRemplissage,
    required this.statut,
    required this.latitude,
    required this.longitude,
  });
  
  /// Crée une instance à partir d'un objet JSON
  factory PoubelleInfo.fromJson(Map<String, dynamic> json) {
    return PoubelleInfo(
      id: json['id'] ?? '',
      niveauRemplissage: json['niveau_remplissage'] ?? 0.0,
      statut: json['statut'] ?? '',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
    );
  }
  
/*
  // En cas de communication avec l'API
  /// Convertit l'instance en objet JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'niveau_remplissage': niveauRemplissage,
      'statut': statut,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
*/
}