import 'package:abiaproject/common/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../controllers/dashboard_controller.dart';
import 'package:abiaproject/partagés/widgets_partagés/nav_bar_sans_plus.dart';

class DashboardScreen extends StatelessWidget {
  final DashboardController dashboardController;
  const DashboardScreen({super.key, required this.dashboardController});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
 
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 600, // Limite la largeur sur les grands écrans
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Graphique circulaire
                  _buildPieChart(),
                  
                  const SizedBox(height: 24),
                  
                  // Graphique à barres
                  _buildBarChart(),
                  
                  // Espace supplémentaire en bas pour éviter que le contenu soit masqué par la barre de navigation
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey.shade50, // Fond plus clair pour améliorer le contraste
      bottomNavigationBar: NavBarSansPlus(
        initialPage: 1,
        onPageChanged: (index) {
          if (index == 1) return; // Déjà sur cette page
          
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/map');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/collecte');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/notifications');
              break;
          }
        },
        useSvgIcons: false,
        icons: const [
          Symbols.distance_rounded,
          Icons.bar_chart_rounded,
          Symbols.delivery_truck_bolt_rounded,
          Symbols.notifications_unread_rounded,
        ],
        colors: const [
          AppColors.primaryColor,
          AppColors.primaryColor,
          AppColors.primaryColor,
          AppColors.primaryColor,
        ],
        iconLabels: const ['Carte', 'Stats', 'Collecte', 'Notifs'],
      )
    );
  }

  Widget _buildPieChart() {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Taux de remplissage moyen',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 60,
                      sections: [
                        PieChartSectionData(
                          value: 12,
                          color: Colors.deepOrange,
                          radius: 60,
                          title: '',
                        ),
                        PieChartSectionData(
                          value: 88,
                          color: Colors.grey.shade200,
                          radius: 60,
                          title: '',
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '12%',
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      Text(
                        'Remplissage',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Légende
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(Colors.deepOrange, 'Rempli'),
                  const SizedBox(width: 24),
                  _buildLegendItem(Colors.grey.shade200, 'Disponible'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Poubelles pleines par jour',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, top: 20),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 200,
                    barGroups: [
                      makeGroupData(0, 200),
                      makeGroupData(1, 120),
                      makeGroupData(2, 50),
                      makeGroupData(3, 20),
                      makeGroupData(4, 150),
                      makeGroupData(5, 200),
                      makeGroupData(6, 130),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: getBottomTitles,
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 50,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            );
                          },
                          reservedSize: 30,
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: 50,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      ),
                      drawVerticalLine: false,
                    ),
                  ),
                ),
              ),
            ),
            // Légende
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(Colors.deepOrange, 'Nombre de poubelles pleines'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.deepOrange,
          width: 16,
          borderRadius: BorderRadius.circular(4),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 200,
            color: Colors.grey.shade100,
          ),
        ),
      ],
    );
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8, // Espace entre le titre et l'axe
      child: Text(
        days[value.toInt()],
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}