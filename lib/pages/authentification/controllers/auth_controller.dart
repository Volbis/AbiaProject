// Cette classe gère l'authentification de l'utilisateur

class AuthController {
    // Variable pour suivre l'état de connexion
  bool _isAuthenticated = false;
  String? _currentUserEmail;

  // Méthode de login modifiée pour mettre à jour l'état de connexion
  Future<bool> login(String email, String password) async {
    // Déclarer des variables pour les identifiants administrateur
    String adminEmail = "admin@example.com";
    String adminPassword = "!Admin123";
    
    // Implémenter la logique de connexion
    if (email == adminEmail && password == adminPassword) {
      // Connexion administrateur réussie
      _isAuthenticated = true;
      _currentUserEmail = email;
      return true;
    }
    return false;
  }

  // Méthode pour vérifier si l'utilisateur est connecté
  bool isLoggedIn() {
    // Retourne l'état actuel de l'authentification
    return _isAuthenticated;
  }
  
  // Obtenir l'email de l'utilisateur connecté
  String? getCurrentUserEmail() {
    return _currentUserEmail;
  }
  
  // Méthode de déconnexion mise à jour
  Future<void> logout() async {
    _isAuthenticated = false;
    _currentUserEmail = null;
  }
}