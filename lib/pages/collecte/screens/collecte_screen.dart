import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../controllers/collecte_controller.dart';
import '../../../common/theme/app_theme.dart';
import '../../../partagés/widgets_partagés/nav_bar_sans_plus.dart';
import 'package:get/get.dart';

class HistoriqueCollectesView extends StatelessWidget {
  final CollecteController collecteController;

  const HistoriqueCollectesView({super.key, required this.collecteController});

  @override
  Widget build(BuildContext context) {
    // Pour déboguer: forcer isLoading à false après 5 secondes
    Future.delayed(const Duration(seconds: 5), () {
      if (collecteController.isLoading.value) {
        collecteController.isLoading.value = false;
      } 
    });
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Historique des collectes',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,  // Limite la largeur sur grands écrans
            ),
            child: Obx(() {
              // Afficher les informations de débogage
              print("IsLoading: ${collecteController.isLoading.value}");
              print("Collections: ${collecteController.collections.length}");
              
              if (collecteController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }
              
              final collections = collecteController.collections;
              if (collections.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Symbols.recycling_rounded,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucun historique de collecte',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: collections.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final collection = collections[index];
                  return CollectionTile(collection: collection, controller: collecteController);
                },
              );
            }),
          ),
        ),
      ),

      bottomNavigationBar: NavBarSansPlus(
        initialPage: 2, // Index pour la page des collectes
        onPageChanged: (index) {
          // Navigation standardisée
          if (index == 2) return; // Déjà sur cette page
          
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/map');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/dashboard');
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
}

class CollectionTile extends StatelessWidget {
  final Collection collection;
  final CollecteController controller;

  const CollectionTile({
    Key? key,
    required this.collection,
    required this.controller,
  }) : super(key: key);

  Color getBinColor() {
    switch (collection.binColor) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'grey':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Afficher plus de détails sur la collecte
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => CollectionDetailsSheet(collection: collection),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icône de poubelle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: getBinColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Symbols.delete_rounded,
                  color: getBinColor(),
                  size: 28,
                  fill: 1,
                ),
              ),
              const SizedBox(width: 16),
              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${collection.binType} ${collection.id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis, // Truncate with ... if too long
                          ),
                        ),
                        const SizedBox(width: 8), // Add some spacing
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            controller.getTimeAgo(collection.collectionTime),
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),         
                    const SizedBox(height: 4),
                    const SizedBox(height: 8),
                    Text(
                      'Collectée par ${collection.truckName}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
 
                  ],
                ),
              ),
              // Flèche indiquant qu'on peut taper
              Icon(
                Symbols.chevron_right_rounded,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CollectionDetailsSheet extends StatelessWidget {
  final Collection collection;

  const CollectionDetailsSheet({
    Key? key,
    required this.collection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final trashBin = collection.trashBin;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // En-tête avec icône
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Symbols.recycling_rounded,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Détails de la collecte',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Détails de la collecte
          _buildDetailSection('Informations générales', [
            _buildDetailRow(Symbols.numbers_rounded, 'ID', collection.id),
            _buildDetailRow(Symbols.local_shipping_rounded, 'Camion', collection.truckName),
          ]),
          
          const SizedBox(height: 16),
          
          _buildDetailSection('Date et heure', [
            _buildDetailRow(
              Symbols.calendar_month_rounded, 
              'Date', 
              '${collection.collectionTime.day}/${collection.collectionTime.month}/${collection.collectionTime.year}'
            ),
            _buildDetailRow(
              Symbols.schedule_rounded, 
              'Heure', 
              '${collection.collectionTime.hour}:${collection.collectionTime.minute.toString().padLeft(2, '0')}'
            ),
          ]),
          
          const SizedBox(height: 16),
          
          _buildDetailSection('Mesures', [
            _buildDetailRow(
              Symbols.weight_rounded, 
              'Quantité collectée', 
              '${collection.quantiteCollectee} kg'
            ),
          ]),
          
          if (trashBin != null) ...[
            const SizedBox(height: 24),
            
            _buildDetailSection('Informations sur la poubelle', [
              _buildDetailRow(Symbols.badge_rounded, 'Nom', trashBin.nomPoubelle),
              _buildDetailRow(Symbols.location_on_rounded, 'Adresse', trashBin.address),
            ]),
          ],
          
          const SizedBox(height: 30),
          
          // Bouton de fermeture
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Fermer'),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}