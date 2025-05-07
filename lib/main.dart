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
import 'pages/collecte/screens/collecte_screen.dart'; // Assurez-vous que cette importation est correcte
import 'pages/dashboard/screens/dashboard_screens.dart'; 
import 'pages/notifications/screens/notifications_screen.dart'; 


void main() {
  // Assurez-vous que Flutter est initialisé
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser les contrôleurs de chaque page
  final authController = AuthController();
  final trashMapController = TrashMapController();
  final collecteController = CollecteController();
  final dashboardController = DashboardController(); 
  final notificationController = NotificationController();
/*
  final dashboardController = DashboardController();
  final collecteController = CollecteController();
  final carteController = CarteController();
  
*/
  runApp(MyApp(
    authController: authController,
    trashMapController: trashMapController,
    collecteController: collecteController, 
    dashboardController: dashboardController,
    notificationController: notificationController,
  ));
}

class MyApp extends StatelessWidget {
  final AuthController authController;
  final TrashMapController trashMapController;
  final CollecteController collecteController;
  final DashboardController dashboardController;
  final NotificationController notificationController; 
  
  const MyApp({
    super.key, 
    required this.authController, 
    required this.trashMapController,
    required this.collecteController,
    required this.dashboardController,
    required this.notificationController,
  });
   
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
        '/collecte': (context) => HistoriqueCollectesView(collecteController: collecteController),
        '/dashboard': (context) => DashboardScreen(dashboardController: dashboardController),  
        '/notifications': (context) => NotificationsScreen(notificationController: notificationController),

      },
    );
  }
}