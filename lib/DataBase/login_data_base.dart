import 'package:mysql1/mysql1.dart';
import 'dart:async';

/// Classe utilitaire pour gérer les connexions à la base de données MySQL.
class DatabaseConnection {
  // Configuration de la base de données
  static final ConnectionSettings _settings = ConnectionSettings(
    host: '127.0.0.1',  
    port: 3306,         
    user: 'root',      
    db: 'abia_db',      
  );
 
  /// Retourne une connexion MySQL utilisable
  static Future<MySqlConnection> getConnection() async {
    try {
      final conn = await MySqlConnection.connect(_settings);
      print("🔌 Connexion à la base de données établie avec succès");
      return conn;
    } catch (e) {
      print("❌ Erreur de connexion à la base de données: $e");
      throw Exception('Impossible de se connecter à la base de données: $e');
    }
  }

  /// Exécute une requête SQL avec des paramètres et retourne les résultats
  static Future<Results> executeQuery(String query, [List<Object>? params]) async {
    final conn = await getConnection();
    try {
      final results = await conn.query(query, params);
      return results;
    } finally {
      await conn.close();
    }
  }

  /// Exécute une procédure stockée et retourne les résultats
  static Future<Results> callProcedure(String procedureName, List<Object> params) async {
    final conn = await getConnection();
    try {
      // Construction de la chaîne d'appel de procédure
      final placeholders = List.generate(params.length, (index) => '?').join(',');
      final query = 'CALL $procedureName($placeholders)';
      
      final results = await conn.query(query, params);
      return results;
    } finally {
      await conn.close();
    }
  }
}