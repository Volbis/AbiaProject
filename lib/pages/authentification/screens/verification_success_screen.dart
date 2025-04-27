import 'package:flutter/material.dart';
import 'package:abiaproject/common/theme/app_theme.dart';
import 'package:material_symbols_icons/symbols.dart';

class VerificationSuccessScreen extends StatelessWidget {
  final VoidCallback onContinue;
  
  const VerificationSuccessScreen({
    super.key, 
    required this.onContinue,
  });
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            size: 40,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icone de validation
             Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryColor.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Symbols.verified_rounded,  
                  color: Colors.white,
                  size: 90,
                  weight: 600,  
                ),
              ),
            ),

            const SizedBox(height: 50),
            
            // Texte de confirmation
            const Text(
              'Vérification réussie',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 14),
            
            // Message secondaire
            const Text(
              'Vous êtes connecté en tant qu\'administrateur',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 70),
            
            // Bouton Continuer
            SizedBox(
              width: 240,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 17,
            
                  ),
                ),
              ),
            ),
          ],
        ),
       ),
    );
  }
}