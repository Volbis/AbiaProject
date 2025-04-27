import 'package:flutter/material.dart';

// Importations des thèmes et constantes
import 'common/theme/app_theme.dart';
import 'common/constants/app_constants.dart';

// Importations des contrôleurs
import 'pages/authentification/controllers/auth_controller.dart';
import 'pages/dashboard/controllers/dashboard_controller.dart';
import 'pages/collecte/controllers/collecte_controller.dart';
import 'pages/carte_Poubelle_manage/controllers/carte_poubelle_controller.dart';
import 'pages/notifications/controllers/notification_controller.dart';

// Importations des pages
import 'pages/authentification/screens/login_screen.dart';
import 'pages/carte_Poubelle_manage/screens/carte_poubelle_screen.dart';
//import 'pages/dashboard/screens/dashboard_screen.dart';

void main() {
  // Assurez-vous que Flutter est initialisé
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser les contrôleurs de chaque page
  final authController = AuthController();
  final trashMapController = TrashMapController();
  
  /*final dashboardController = DashboardController();
  final collecteController = CollecteController();
  final carteController = CarteController();
  final notificationController = NotificationController();
  */
  runApp(MyApp(
    authController: authController,
    trashMapController: trashMapController,
    //dashboardController: dashboardController,
  ));
}

class MyApp extends StatelessWidget {
  final AuthController authController;
  final TrashMapController trashMapController;
  //final DashboardController dashboardController;
  
  const MyApp({
    super.key, 
    required this.authController, 
    required this.trashMapController,
    //required this.dashboardController
  });
   
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Abia - La Poubelle Intelligente',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryColor,
          primary: AppColors.primaryColor,
          secondary: AppColors.secondaryColor,
          background: AppColors.backgroundColor,
          surface: AppColors.surfaceColor
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textPrimary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFDFE2E5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFFE554A)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFE554A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(authController: authController),
        '/map': (context) => TrashMapScreen(trashMapController: trashMapController),
        //'/dashboard': (context) => DashboardScreen(dashboardController: dashboardController),
        // Ajoutez ici les autres routes
      },
    );
  }
}