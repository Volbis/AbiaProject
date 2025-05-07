import 'package:flutter/material.dart';

class NotificationController {
  // Liste des notifications
  List<NotificationItem> getNotifications() {
    return [
      NotificationItem(
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.red,
        title: "Poubelle pleine",
        description: "La poubelle QK117 est actuellement pleine.",
        time: "il y a 5 min",
      ),
      NotificationItem(
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.red,
        title: "Poubelle pleine",
        description: "La poubelle QK117 est actuellement pleine.",
        time: "il y a 34 min",
      ),
      NotificationItem(
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.red,
        title: "Poubelle pleine",
        description: "La poubelle QK117 est actuellement pleine.",
        time: "il y a 4 h",
      ),
      NotificationItem(
        icon: Icons.thermostat,
        iconColor: Colors.orange,
        title: "Température anormale",
        description: "La température de la poubelle CD453 est actuellement trop élevée.",
        time: "il y a 12 h",
      ),
      NotificationItem(
        icon: Icons.error_outline,
        iconColor: Colors.green,
        title: "Couvercle bloqué ou endommagé",
        description: "La poubelle CD453 a son couvercle mal fermé ou endommagé.",
        time: "il y a 15 h",
      ),
      NotificationItem(
        icon: Icons.build_circle,
        iconColor: Colors.blue,
        title: "Rappel de maintenance",
        description: "La poubelle QK117 a besoin de maintenance.",
        time: "il y a 1 j",
      ),
      NotificationItem(
        icon: Icons.build_circle,
        iconColor: Colors.blue,
        title: "Rappel de maintenance",
        description: "La poubelle CD453 a besoin de maintenance.",
        time: "il y a 2 j",
      ),
      NotificationItem(
        icon: Icons.thermostat,
        iconColor: Colors.orange,
        title: "Température anormale",
        description: "La température de la poubelle QK117 est actuellement trop élevée.",
        time: "il y a 12 h",
      ),
    ];
  }

  // Obtenir les notifications par type
  List<NotificationItem> getNotificationsByType(String type) {
    final allNotifications = getNotifications();
    
    switch (type) {
      case 'error':
        return allNotifications.where((n) => n.iconColor == Colors.red).toList();
      case 'warning':
        return allNotifications.where((n) => n.iconColor == Colors.orange).toList();
      case 'info':
        return allNotifications.where((n) => n.iconColor == Colors.blue).toList();
      case 'success':
        return allNotifications.where((n) => n.iconColor == Colors.green).toList();
      default:
        return allNotifications;
    }
  }

  // Obtenir les notifications pour une poubelle spécifique
  List<NotificationItem> getNotificationsByBin(String binId) {
    final allNotifications = getNotifications();
    return allNotifications.where((n) => n.description.contains(binId)).toList();
  }

  // Marquer une notification comme lue (à implémenter selon vos besoins)
  void markAsRead(int index) {
    // Logique pour marquer une notification comme lue
    // Cette fonctionnalité nécessiterait une gestion d'état plus avancée
  }

  // Supprimer une notification
  List<NotificationItem> deleteNotification(List<NotificationItem> notifications, int index) {
    final updatedList = List<NotificationItem>.from(notifications);
    updatedList.removeAt(index);
    return updatedList;
  }
}

class NotificationItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String time;
  final bool isRead;

  NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.time,
    this.isRead = false,
  });

  // Créer une copie avec modification
  NotificationItem copyWith({
    IconData? icon,
    Color? iconColor,
    String? title,
    String? description,
    String? time,
    bool? isRead,
  }) {
    return NotificationItem(
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
    );
  }
}