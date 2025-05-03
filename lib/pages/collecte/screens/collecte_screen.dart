import 'package:flutter/material.dart';
import '../controllers/collecte_controller.dart';
import '../../../common/theme/app_theme.dart';

class HistoriqueCollectesView extends StatelessWidget {
  final CollecteController collecteController;

  const HistoriqueCollectesView({super.key, required this.collecteController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Historiques des collectes',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: ValueNotifier(collecteController.isLoading.value),
        builder: (context, isLoading, _) {
          if (isLoading) {
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
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavBarItem(Icons.person_outline, 0),
            _buildNavBarItem(Icons.bar_chart, 1, isSelected: true),
            _buildNavBarItem(Icons.chat_bubble_outline, 2),
            _buildNavBarItem(Icons.notifications_none, 3),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNavBarItem(IconData icon, int index, {bool isSelected = false}) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
      ),
      child: Icon(
        icon,
        color: isSelected ? AppColors.primaryColor : Colors.grey,
        size: 24,
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