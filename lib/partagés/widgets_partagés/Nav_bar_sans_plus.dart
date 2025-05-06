import 'package:flutter/material.dart';
import 'package:abiaproject/common/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Une barre de navigation flottante simple sans bouton plus central.
/// Ce widget est conçu pour être utilisé comme bottomNavigationBar dans un Scaffold.
class NavBarSansPlus extends StatefulWidget {
  /// L'index initial de la page sélectionnée
  final int initialPage;

  /// Liste des noms à afficher sous chaque icône
  final List<String> iconLabels;
  
  /// Callback appelé quand l'utilisateur change de page
  final Function(int) onPageChanged;
  
  /// Liste des chemins d'icônes SVG ou IconData à afficher dans la barre
  final List<dynamic> icons;
  
  /// Liste des couleurs pour chaque icône (doit correspondre à la longueur de icons)
  final List<Color> colors;
  
  /// Indique si les icônes sont des SVG (true) ou des IconData (false)
  final bool useSvgIcons;

  const NavBarSansPlus({
    super.key,
    this.initialPage = 0,
    required this.onPageChanged,
    required this.icons,
    this.colors = const [
      Colors.blue,
      Colors.blue,
      Colors.blue,
      Colors.blue,
    ],
    this.iconLabels = const ['Accueil', 'Recherche', 'Profil', 'Paramètres'],
    this.useSvgIcons = false,
  });

  @override
  State<NavBarSansPlus> createState() => _NavBarSansPlusState();
}

class _NavBarSansPlusState extends State<NavBarSansPlus> with SingleTickerProviderStateMixin {
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
    final unselectedColor = Colors.grey;
    final size = MediaQuery.of(context).size;
    
    return SizedBox(
      height: 100,
      child: Stack(
        children: [
          // Barre de navigation avec forme simplifiée
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              width: size.width,
              height: 100,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Forme de la barre
                  CustomPaint(
                    size: Size(size.width, 100),
                    painter: SimplifiedNavBarPainter(),
                  ),
                  
                  // Contenu de la barre (icônes)
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(widget.icons.length, (index) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              icon: widget.useSvgIcons
                                  ? SvgPicture.asset(
                                      widget.icons[index],
                                      width: 24,
                                      height: 24,
                                      colorFilter: ColorFilter.mode(
                                        currentPage == index ? widget.colors[index] : unselectedColor,
                                        BlendMode.srcIn
                                      ),
                                    )
                                  : Icon(
                                      widget.icons[index] as IconData,
                                      color: currentPage == index ? widget.colors[index] : unselectedColor,
                                      size: 30,
                                    ),
                              onPressed: () => changePage(index),
                            ),
                            // N'affiche le texte que si l'icône est sélectionnée
                            Visibility(
                              visible: currentPage == index,
                              maintainSize: false,
                              maintainAnimation: false,
                              maintainState: false,
                              child: Text(
                                widget.iconLabels[index],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: widget.colors[index],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter pour dessiner la forme simplifiée de la barre de navigation
class SimplifiedNavBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    // Le chemin de la barre sans creux au centre
    Path path = Path()
      ..moveTo(0, 35)
      ..quadraticBezierTo(0, 0, size.width * 0.125, 0)
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