import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../controllers/collecte_controller.dart';
import '../../../common/theme/app_theme.dart';
import '../../../partagés/widgets_partagés/nav_bar_avec_plus.dart';
import 'package:get/get.dart';

class HistoriqueCollectesView extends StatelessWidget {
  final CollecteController collecteController;

  const HistoriqueCollectesView({super.key, required this.collecteController});

  @override
  Widget build(BuildContext context) {
    // Pour déboguer: forcer isLoading à false après 5 secondes
    Future.delayed(Duration(seconds: 5), () {
      if (collecteController.isLoading.value) {
        collecteController.isLoading.value = false;
      }
    });
    
    return Scaffold(
      backgroundColor: Colors.white,
      // Suppression de l'AppBar
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // En-tête personnalisé avec le texte et bouton retour
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centrer les éléments dans la rangée
              children: [
                const Text(
                  'Historiques des collectes',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
            // Contenu principal
            Expanded(
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
                  return const Center(
                    child: Text(
                      'Aucun historique de collecte',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: collections.length,
                  itemBuilder: (context, index) {
                    final collection = collections[index];
                    return CollectionTile(collection: collection, controller: collecteController);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavBarAvecPlus(
        initialPage: 3, // Index pour la page des collectes
        onPageChanged: (index) {
          // Navigation standardisée
          if (index == 3) return; // Déjà sur cette page
          
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/map');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/stats');
              break;
            case 2:
              // Position du bouton +, gérer séparément
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
        onPlusButtonPressed: () {
          // Action du bouton + spécifique à cette page
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Ajouter une collecte'),
              content: const Text('Fonctionnalité à implémenter'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
              ],
            ),
          );
        },
        useSvgIcons: false,
        icons: const [
          Symbols.distance_rounded,
          Icons.bar_chart_rounded,
          Icons.add,
          Symbols.delivery_truck_bolt_rounded,
          Symbols.notifications_unread_rounded,
        ],
        colors: const [
          AppColors.primaryColor,
          AppColors.primaryColor,
          AppColors.primaryColor,
          AppColors.primaryColor,
          AppColors.primaryColor,
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: getBinColor(),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${collection.binType} ${collection.id}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              controller.getTimeAgo(collection.collectionTime),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              'La poubelle collectée par le camion',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              collection.truckName,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () {
          // Afficher plus de détails sur la collecte
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => CollectionDetailsSheet(collection: collection),
          );
        },
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
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Détails de la collecte',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('ID de collecte', collection.id),
          _buildDetailRow('Type de poubelle', collection.binType),
          _buildDetailRow('Camion', collection.truckName),
          _buildDetailRow('Date de collecte', 
              '${collection.collectionTime.day}/${collection.collectionTime.month}/${collection.collectionTime.year}'),
          _buildDetailRow('Heure', 
              '${collection.collectionTime.hour}:${collection.collectionTime.minute.toString().padLeft(2, '0')}'),
          _buildDetailRow('Quantité collectée', '${collection.quantiteCollectee} kg'),
          
          if (trashBin != null) ...[
            const SizedBox(height: 20),
            const Text(
              'Informations sur la poubelle',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Nom', trashBin.nomPoubelle),
            _buildDetailRow('Adresse', trashBin.address),
            _buildDetailRow('Capacité totale', '${trashBin.capaciteTotale} kg'),
          ],
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 4),
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