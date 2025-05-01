import 'package:mysql1/mysql1.dart';
import 'dart:async';

/// Classe utilitaire pour gérer les connexions à la base de données MySQL.
class DatabaseConnection {
  // Configuration de la base de données
  static final ConnectionSettings _settings = ConnectionSettings(
    host: '10.0.2.2',  
    port: 3306,         
    user: 'flutter_user',   
    password: 'votre_password',   
    db: 'abia_db',      
    timeout: Duration(seconds: 240),
  );
 
  /// Retourne une connexion MySQL utilisable
  static Future<MySqlConnection> getConnection() async {
    try {
      final conn = await MySqlConnection.connect(_settings);
      print("👌 Connexion à la base de données🔌établie avec succès");
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
    MySqlConnection? conn;
    int retryCount = 0;
    const maxRetries = 5;
    
    while (retryCount < maxRetries) {
      try {
        conn = await getConnection();
        
        // Construction de la chaîne d'appel de procédure
        final placeholders = List.generate(params.length, (index) => '?').join(',');
        final query = 'CALL $procedureName($placeholders)';
        
        final results = await conn.query(query, params);
        return results;
      } catch (e) {
        retryCount++;
        print("🔄 Tentative $retryCount après erreur: $e");
        
        if (retryCount >= maxRetries) {
          throw Exception('Échec après $maxRetries tentatives: $e');
        }
        
        // Attendre avant de réessayer
        await Future.delayed(Duration(seconds: 1));
      } finally {
        await conn?.close();
      }
    }
    
    throw Exception('Impossible d\'exécuter la procédure stockée');
  }
}