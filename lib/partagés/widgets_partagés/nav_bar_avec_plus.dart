import 'package:flutter/material.dart';
import 'package:abiaproject/common/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Une barre de navigation flottante avec un bouton plus au centre et une forme incurvée.
/// Ce widget est conçu pour être utilisé comme bottomNavigationBar dans un Scaffold.
class NavBarAvecPlus extends StatefulWidget {
  /// L'index initial de la page sélectionnée
  final int initialPage;
  
  /// Callback appelé quand l'utilisateur change de page
  final Function(int) onPageChanged;
  
  /// Liste des chemins d'icônes SVG à afficher dans la barre (doit contenir 5 éléments)
  final List<dynamic> icons;
  
  /// Liste des couleurs pour chaque icône (doit correspondre à la longueur de icons)
  final List<Color> colors;
  
  /// Callback appelé quand l'utilisateur appuie sur le bouton + central
  final Function? onPlusButtonPressed;
  
  /// Indique si les icônes sont des SVG (true) ou des IconData (false)
  final bool useSvgIcons;

  const NavBarAvecPlus({
    super.key,
    this.initialPage = 0,
    required this.onPageChanged,
    required this.icons,
    this.colors = const [
      Colors.blue,
      Colors.blue,
      Colors.blue,
      Colors.blue,
      Colors.blue,
    ],
    this.onPlusButtonPressed,
    this.useSvgIcons = false,
  });

  @override
  State<NavBarAvecPlus> createState() => _NavBarAvecPlusState();
}

class _NavBarAvecPlusState extends State<NavBarAvecPlus> with SingleTickerProviderStateMixin {
  late int currentPage;
  late TabController tabController;

  @override
  void initState() {
    currentPage = widget.initialPage;
    tabController = TabController(
      length: widget.icons.length, 
      vsync: this,
      initialIndex: currentPage,
    );
    
    tabController.animation?.addListener(() {
      final value = tabController.animation!.value.round();
      if (value != currentPage && mounted) {
        changePage(value);
      }
    });
    
    super.initState();
  }

  void changePage(int newPage) {
    // Ne changez pas la page si c'est le bouton du milieu (index 2)
    if (newPage == 2) {
      if (widget.onPlusButtonPressed != null) {
        widget.onPlusButtonPressed!();
      }
      return;
    }
    
    setState(() {
      currentPage = newPage;
    });
    widget.onPageChanged(newPage);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor;
    final unselectedColor = Colors.grey;
    final size = MediaQuery.of(context).size;
    
    // Retourne seulement le widget de navigation avec une forme incurvée
    return SizedBox(
      height: 140,
      child: Stack(
        children: [
          // Barre de navigation avec forme personnalisée
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              width: size.width,
              height: 94,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Forme personnalisée de la barre
                  CustomPaint(
                    size: Size(size.width, 100),
                    painter: NavBarPainter(),
                  ),
                  
                  // Contenu de la barre (icônes) - APPROCHE DIRECTE SANS _buildIconButton
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Icônes de gauche
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Première icône (index 0)
                              IconButton(
                                icon: widget.useSvgIcons
                                    ? SvgPicture.asset(
                                        'assets/icon_svg/map.svg',
                                        width: 24,
                                        height: 24,
                                        colorFilter: ColorFilter.mode(
                                          currentPage == 0 ? widget.colors[0] : unselectedColor,
                                          BlendMode.srcIn
                                        ),
                                      )
                                    : Icon(
                                        widget.icons[0] as IconData,
                                        color: currentPage == 0 ? widget.colors[0] : unselectedColor,
                                        size: 30,
                                      ),
                                onPressed: () => changePage(0),
                              ),
                              
                              // Deuxième icône (index 1)
                              IconButton(
                                icon: widget.useSvgIcons
                                    ? SvgPicture.asset(
                                        'assets/icon_svg/notif.svg',
                                        width: 24,
                                        height: 24,
                                        colorFilter: ColorFilter.mode(
                                          currentPage == 1 ? widget.colors[1] : unselectedColor,
                                          BlendMode.srcIn
                                        ),
                                      )
                                    : Icon(
                                        widget.icons[1] as IconData,
                                        color: currentPage == 1 ? widget.colors[1] : unselectedColor,
                                        size: 30,
                                        weight: 600,
                                      ),
                                onPressed: () => changePage(1),
                              ),
                            ],
                          ),
                        ),
                        
                        // Espace pour le bouton +
                        const SizedBox(width: 70),
                        
                        // Icônes de droite
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Quatrième icône (index 3)
                              IconButton(
                                icon: widget.useSvgIcons
                                    ? SvgPicture.asset(
                                        'assets/icon_svg/stats.svg',
                                        width: 24,
                                        height: 24,
                                        colorFilter: ColorFilter.mode(
                                          currentPage == 3 ? widget.colors[3] : unselectedColor,
                                          BlendMode.srcIn
                                        ),
                                      )
                                    : Icon(
                                        widget.icons[3] as IconData,
                                        color: currentPage == 3 ? widget.colors[3] : unselectedColor,
                                        size: 30,
                                        weight: 600,
                                      ),
                                onPressed: () => changePage(3),
                              ),
                              
                              // Cinquième icône (index 4)
                              IconButton(
                                icon: widget.useSvgIcons
                                    ? SvgPicture.asset(
                                        'assets/icon_svg/truck.svg',
                                        width: 24,
                                        height: 24,
                                        colorFilter: ColorFilter.mode(
                                          currentPage == 4 ? widget.colors[4] : unselectedColor,
                                          BlendMode.srcIn
                                        ),
                                      )
                                    : Icon(
                                        widget.icons[4] as IconData,
                                        color: currentPage == 4 ? widget.colors[4] : unselectedColor,
                                        size: 30,
                                        opticalSize: 20,
                                        weight: 600,
                                      ),
                                onPressed: () => changePage(4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bouton + flottant
          Positioned(
            bottom: 55, // Ajusté pour être centré dans le creux
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4F80FF), // Couleur bleue comme dans l'image
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F80FF).withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: widget.useSvgIcons 
                      ? SvgPicture.asset(
                          'assets/icon_svg/add.svg', // Chemin fixe pour l'icône +
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          height: 24,
                          width: 24,
                        )
                      : const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 30,
                        ),
                  onPressed: () {
                    if (widget.onPlusButtonPressed != null) {
                      widget.onPlusButtonPressed!();
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // La méthode _buildIconButton est supprimée car nous n'en avons plus besoin
}

/// CustomPainter pour dessiner la forme de la barre de navigation avec le creux au centre
class NavBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    // Le chemin de la barre avec un creux vers le haut au centre
    Path path = Path()
      ..moveTo(0, 35)
      ..quadraticBezierTo(0, 0, size.width * 0.125, 0)
      ..lineTo(size.width * 0.300, 0)
      ..quadraticBezierTo(size.width * 0.375, 0, size.width * 0.385, 20)
      ..arcToPoint(
        Offset(size.width * 0.615, 20),
        radius: const Radius.circular(50.0),
        clockwise: false
      )
      ..quadraticBezierTo(size.width * 0.625, 0, size.width * 0.70, 0)
      ..lineTo(size.width * 0.875, 0)
      ..quadraticBezierTo(size.width, 0, size.width, 35)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    // Ajouter une ombre légère
    Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    Path shadowPath = path.shift(const Offset(0, 2));
    canvas.drawPath(shadowPath, shadowPaint);
    
    // Dessiner la barre principale
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}