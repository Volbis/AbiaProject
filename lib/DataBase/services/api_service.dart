import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2/api_mysql.php'; 
  
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'test'}),
      );
      
      print('Réponse test API: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur test API: $e');
      throw Exception('Erreur de test de connexion: $e');
    }
  }
  
  static Future<Map<String, dynamic>> creerPoubelle({
    required double capacite, 
    required String statut,
    required double latitude,
    required double longitude,
    required String adresse,
    required String nom
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'creer_poubelle',
          'capacite': capacite,
          'statut': statut,
          'latitude': latitude,
          'longitude': longitude,
          'adresse': adresse,
          'nom': nom
        }),
      ).timeout(Duration(seconds: 60));
      
      print('Réponse brute de l\'API: ${response.body}');
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result.containsKey('error')) {
          throw Exception(result['error']);
        }
        return result;
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur API: $e');
      throw Exception('Erreur API: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllTrashBins() async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'get_all_bins'}),
      );
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result.containsKey('error')) {
          throw Exception(result['error']);
        }
        return List<Map<String, dynamic>>.from(result['bins']);
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur API: $e');
      throw Exception('Erreur lors de la récupération des poubelles: $e');
    }
  }

}