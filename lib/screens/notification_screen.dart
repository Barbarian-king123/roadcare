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
  List<AppNotification> notifications = [
    AppNotification(
      message: 'Your reported issue "Large Pothole on Main Road" has been acknowledged by municipal maintenance team.',
      timestamp: 'Today · 11:00 AM',
      type: NotificationType.info,
      isRead: false,
    ),
    AppNotification(
      message: 'Issue "Broken Street Light" status updated to In Progress. Repair scheduled for tonight.',
      timestamp: 'Yesterday · 09:30 PM',
      type: NotificationType.warning,
      isRead: false,
    ),
    AppNotification(
      message: 'Your report "Damaged Manhole Cover" has been verified and marked as Resolved!',
      timestamp: '2 days ago · 05:20 PM',
      type: NotificationType.success,
      isRead: true,
    ),
    AppNotification(
      message: '3 new road issues reported in your neighborhood within 2 km.',
      timestamp: '3 days ago · 02:10 PM',
      type: NotificationType.general,
      isRead: true,
    ),
    AppNotification(
      message: 'Thank you for making our streets safer! You earned the Active Citizen badge.',
      timestamp: '4 days ago · 10:00 AM',
      type: NotificationType.thanks,
      isRead: true,
    ),
  ];

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return Icons.notifications;
      case NotificationType.warning:
        return Icons.build_circle_outlined;
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.general:
        return Icons.location_on_outlined;
      case NotificationType.thanks:
        return Icons.star_rounded;
    }
  }

  Color _colorFor(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return const Color(0xFF2563EB);
      case NotificationType.warning:
        return const Color(0xFFD97706);
      case NotificationType.success:
        return const Color(0xFF16A34A);
      case NotificationType.general:
        return const Color(0xFF0284C7);
      case NotificationType.thanks:
        return const Color(0xFFEAB308);
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

  void _markAllAsRead() {
    setState(() {
      notifications = notifications.map((n) {
        return AppNotification(
          message: n.message,
          timestamp: n.timestamp,
          type: n.type,
          isRead: true,
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              "Mark all read",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
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
                      color: notif.isRead ? Colors.white : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: notif.isRead ? const Color(0xFFE2E8F0) : const Color(0xFFBFDBFE),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _colorFor(notif.type).withValues(alpha: 0.12),
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
                                  fontWeight: notif.isRead ? FontWeight.normal : FontWeight.w700,
                                  color: const Color(0xFF0F172A),
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
                            margin: const EdgeInsets.only(top: 6, left: 6),
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