import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'package:abiaproject/common/theme/app_theme.dart';
import '../screens/verification_success_screen.dart';

class LoginScreen extends StatefulWidget {
  final AuthController authController;
  
  const LoginScreen({super.key, required this.authController});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });
    
      // Utiliser le contrôleur pour la logique de connexion
      final success = await widget.authController.login(
        _emailController.text,
        _passwordController.text,
      );
      print("Login success: $success"); // Debugging line
      
      setState(() {
        _isLoading = false;
      });
      
      if (success && mounted) {
        // Afficher l'écran de confirmation au lieu de naviguer directement
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationSuccessScreen(
              onContinue: () {
                // Lors du clic sur Continue, naviguer vers le dashboard
                //Navigator.pushReplacementNamed(context, '/dashboard');
              },
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Échec de la connexion')),
        );
      }
    }
  /*
  void _handleGoogleLogin() async {
     
    setState(() {
      _isLoading = true;
    });
   
    try {
      // Utiliser le contrôleur d'authentification pour la connexion Google
      final success = await widget.authController.loginWithGoogle();
      
      if (success && mounted) {
        // Navigation vers le dashboard en cas de succès
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else if (mounted) {
        // Afficher un message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Échec de la connexion avec Google')),
        );
      }
    } catch (e) {
      // Gérer les erreurs spécifiques
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      // S'assurer que l'indicateur de chargement est toujours désactivé
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } 
    
}
  */
  
  /*====LE DESIGN DE LA PAGE====*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
              icon: const Icon(
                Icons.chevron_left,  
                color: AppColors.textPrimary,
                size: 40,  
              ), 
             onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              
              // Avatar circulaire
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromARGB(119, 227, 227, 227),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 40,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 24),

              // Titre "SE CONNECTER"
              const Text(
                'SE CONNECTER',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height:80),

              // Champ email
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Entrez votre adresse mail',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 15,
                      ),
                      hintText: 'exemple@email.com',  // Placeholder pour le champ email
                      hintStyle: TextStyle(
                        color: Colors.grey[400],  // Couleur plus claire pour le placeholder
                        fontSize: 15,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Champ mot de passe
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Entrez votre mot de passe',
                    style: TextStyle(
                      fontSize: 15, 
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 15,
                      ),
                      hintText: '..............',  
                      hintStyle: TextStyle(
                        color: Colors.grey[400], 
                        fontSize: 17,
                      ),
                    ),
                    obscureText: true,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Bouton Se connecter
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Se connecter',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                           fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 27),
              /*
              // OU séparateur
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OU',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 24),

              // Bouton Google
              SizedBox(
                width: 200,
                child: OutlinedButton.icon(
                  icon: Image.asset('assets/images/google_icon.png', height: 25, width: 25),
                  label: const Text(
                    'Continuer avec Google',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color.fromARGB(189, 220, 220, 220),
                  ),
                  onPressed: _isLoading ? null : _handleGoogleLogin,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: Image.asset('assets/images/google_icon.png', height: 25, width: 25,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 20)),
                  label: const Text(
                    'Continuer avec Google',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color.fromARGB(189, 220, 220, 220),
                  ),
                  onPressed: _isLoading ? null : _handleGoogleLogin,
                ),
              ),*/
              
              const SizedBox(height: 18),

            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}


