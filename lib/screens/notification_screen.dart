import 'package:flutter/material.dart';

enum NotificationType { info, warning, success, general, thanks }

class AppNotification {
  final String message;
  final String timestamp;
  final NotificationType type;
  final bool isRead;

  AppNotification({
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Dummy data — will be replaced with a Firestore stream once backend is wired up.
  List<AppNotification> notifications = [
    AppNotification(
      message: 'Your reported issue "Pothole" has been acknowledged.',
      timestamp: '20 May 2024 \u00b7 11:00 AM',
      type: NotificationType.info,
      isRead: false,
    ),
    AppNotification(
      message: 'Issue "Broken Street Light" status changed to In Progress.',
      timestamp: '19 May 2024 \u00b7 09:30 PM',
      type: NotificationType.warning,
      isRead: false,
    ),
    AppNotification(
      message: 'Your issue "Water Leakage" has been resolved.',
      timestamp: '18 May 2024 \u00b7 05:20 PM',
      type: NotificationType.success,
      isRead: true,
    ),
    AppNotification(
      message: 'New issue reported near you.',
      timestamp: '17 May 2024 \u00b7 02:10 PM',
      type: NotificationType.general,
      isRead: true,
    ),
    AppNotification(
      message: 'Thank you for making your city better!',
      timestamp: '16 May 2024 \u00b7 10:00 AM',
      type: NotificationType.thanks,
      isRead: true,
    ),
  ];

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return Icons.notifications;
      case NotificationType.warning:
        return Icons.error_outline;
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.general:
        return Icons.location_on;
      case NotificationType.thanks:
        return Icons.star;
    }
  }

  Color _colorFor(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return const Color(0xFF2563EB);
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.success:
        return Colors.green;
      case NotificationType.general:
        return Colors.blueGrey;
      case NotificationType.thanks:
        return Colors.amber.shade700;
    }
  }

  void _markAsRead(int index) {
    setState(() {
      notifications[index] = AppNotification(
        message: notifications[index].message,
        timestamp: notifications[index].timestamp,
        type: notifications[index].type,
        isRead: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        title: const Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    "No notifications yet.",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return GestureDetector(
                  onTap: () => _markAsRead(index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _colorFor(notif.type).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_iconFor(notif.type), color: _colorFor(notif.type), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notif.message,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: notif.isRead ? FontWeight.normal : FontWeight.w600,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                notif.timestamp,
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 4, left: 6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}