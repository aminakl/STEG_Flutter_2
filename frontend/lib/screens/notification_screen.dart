import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notification.dart' as app_notification;
import '../providers/notification_provider.dart';
import '../utils/theme_utils.dart';
import '../widgets/app_drawer.dart';
import '../widgets/auto_refresh_wrapper.dart';

class NotificationScreen extends StatefulWidget {
  static const routeName = '/notifications';

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch notifications when screen loads
    Future.microtask(() =>
        Provider.of<NotificationProvider>(context, listen: false)
            .fetchNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return AutoRefreshWrapper(
      onRefresh: _fetchNotifications,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          actions: [
            IconButton(
              icon: Icon(Icons.check_circle_outline),
              tooltip: 'Mark all as read',
              onPressed: () {
                _showMarkAllAsReadDialog(context);
              },
            ),
          ],
        ),
        drawer: AppDrawer(),
        body: _buildNotificationsList(),
      ),
    );
  }

  void _fetchNotifications() {
    Provider.of<NotificationProvider>(context, listen: false)
        .fetchNotifications();
  }

  Widget _buildNotificationsList() {
    return Consumer<NotificationProvider>(
      builder: (ctx, notificationProvider, child) {
        if (notificationProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (notificationProvider.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No notifications yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => notificationProvider.fetchNotifications(),
          child: ListView.builder(
            itemCount: notificationProvider.notifications.length,
            itemBuilder: (ctx, index) {
              final notification = notificationProvider.notifications[index];
              return _buildNotificationItem(context, notification);
            },
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(
      BuildContext context, app_notification.Notification notification) {
    Color typeColor = HexColor(notification.typeColor);
    bool isUnread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (!notification.isRead) {
          // Mark as read when dismissing
          await Provider.of<NotificationProvider>(context, listen: false)
              .markAsRead(notification.id);
        }
        // Don't actually dismiss, just mark as read
        return false;
      },
      child: Card(
        elevation: isUnread ? 3 : 1,
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: isUnread ? Colors.white : Colors.grey[50],
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: typeColor.withOpacity(0.2),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: typeColor,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width *
                    0.7, // Dynamic width based on screen size
                child: Text(
                  notification.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 4),
              Text(
                notification.formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          isThreeLine: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          trailing: isUnread
              ? Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: () {
            if (isUnread) {
              Provider.of<NotificationProvider>(context, listen: false)
                  .markAsRead(notification.id);
            }

            // If there's a related note, navigate to it
            if (notification.relatedNoteId != null) {
              // Navigate to note detail screen
              Navigator.of(context).pushNamed(
                '/note_details',
                arguments: notification.relatedNoteId,
              );
            }
          },
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'NOTE_CREATED':
        return Icons.note_add;
      case 'NOTE_VALIDATED_CHEF_BASE':
      case 'NOTE_VALIDATED_CHARGE_EXPLOITATION':
        return Icons.check_circle;
      case 'NOTE_REJECTED':
        return Icons.cancel;
      case 'NOTE_ASSIGNED':
        return Icons.assignment_ind;
      case 'CONSIGNATION_STARTED':
      case 'CONSIGNATION_COMPLETED':
        return Icons.lock;
      case 'DECONSIGNATION_STARTED':
      case 'DECONSIGNATION_COMPLETED':
        return Icons.lock_open;
      default:
        return Icons.notifications;
    }
  }

  void _showMarkAllAsReadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Mark All as Read'),
        content:
            Text('Are you sure you want to mark all notifications as read?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: Text('Mark All'),
            onPressed: () {
              Provider.of<NotificationProvider>(context, listen: false)
                  .markAllAsRead();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}

// Helper class to convert hex color string to Color
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
