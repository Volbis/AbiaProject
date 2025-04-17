// Cette classe gère l'authentification de l'utilisateur

class AuthController {
  // Méthode de login
  Future<bool> login(String email, String password) async {
    // Implémenter la logique de connexion
    return email.isNotEmpty && password.isNotEmpty;
  }

  Future<bool> loginWithGoogle() async {
  // Ici, implémentez la logique de connexion avec Google
  // Pour l'instant, retournons true pour simuler un succès
  await Future.delayed(Duration(milliseconds: 500)); // Simuler un délai réseau
  return true;
}
  
  // Méthode pour vérifier si l'utilisateur est connecté
  bool isLoggedIn() {
    // Implémenter la vérification
    return false;
  }
  
  // Méthode de déconnexion
  Future<void> logout() async {
    // Implémenter la logique de déconnexion
  }
}