import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isAppBar;

  const NotificationBadge({
    Key? key,
    required this.child,
    required this.onTap,
    this.isAppBar = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (ctx, notificationProvider, _) {
        // Force refresh unread count
        if (notificationProvider.unreadCount == 0) {
          Future.microtask(() => notificationProvider.fetchNotifications(silent: true));
        }
        
        final unreadCount = notificationProvider.unreadCount;
        
        return Stack(
          clipBehavior: Clip.none, // Allow badge to overflow
          children: [
            GestureDetector(
              onTap: onTap,
              child: child,
            ),
            if (unreadCount > 0)
              Positioned(
                top: isAppBar ? 5 : 0,
                right: isAppBar ? 5 : 0,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
