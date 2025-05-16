import 'package:abiaproject/common/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../controllers/notification_controller.dart';
import 'package:abiaproject/partagés/widgets_partagés/nav_bar_sans_plus.dart';

class NotificationsScreen extends StatefulWidget {
  final NotificationController notificationController;

  const NotificationsScreen({
    super.key,
    required this.notificationController,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationController _controller = NotificationController();
  late List<NotificationItem> notifications;

  @override
  void initState() {
    super.initState();
    notifications = _controller.getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Supprime la flèche de retour
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_alt_rounded),
            onSelected: (value) {
              setState(() {
                if (value == 'all') {
                  notifications = _controller.getNotifications();
                } else {
                  notifications = _controller.getNotificationsByType(value);
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('Toutes les notifications'),
              ),
              const PopupMenuItem(
                value: 'error',
                child: Text('Erreurs'),
              ),
              const PopupMenuItem(
                value: 'warning',
                child: Text('Avertissements'),
              ),
              const PopupMenuItem(
                value: 'info',
                child: Text('Informations'),
              ),
              const PopupMenuItem(
                value: 'success',
                child: Text('Succès'),
              ),
            ],
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                'Aucune notification',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Dismissible(
                  key: Key('${notif.title}-${notif.time}-$index'),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    setState(() {
                      notifications = _controller.deleteNotification(notifications, index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notification supprimée')),
                    );
                  },
                  child: ListTile(
                    leading: Icon(notif.icon, color: notif.iconColor, size: 30),
                    title: Text(
                      notif.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: notif.isRead ? Colors.grey : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      notif.description,
                      style: TextStyle(
                        color: notif.isRead ? Colors.grey : Colors.black87,
                      ),
                    ),
                    trailing: Text(
                      notif.time,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    onTap: () {
                      // Vous pourriez ajouter ici une action quand l'utilisateur
                      // touche une notification (afficher plus de détails, etc.)
                      _controller.markAsRead(index);
                      // Note: Cette fonction ne changera pas l'état visuel
                      // car la gestion d'état n'est pas implémentée dans le contrôleur
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Rafraîchir les notifications
          setState(() {
            notifications = _controller.getNotifications();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notifications rafraîchies')),
          );
        },
        backgroundColor: AppColors.primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26), 
        ),
        child: const Icon(
          Icons.refresh,
          color: Colors.white,
          ),
      ),
      bottomNavigationBar: NavBarSansPlus(
        initialPage: 3,
        onPageChanged: (index) {
          if (index == 3) return; // Déjà sur cette page
          
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