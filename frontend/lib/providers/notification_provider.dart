import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';
import '../utils/auth_utils.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  List<Notification> _notifications = [];
  List<Notification> _unreadNotifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  Timer? _refreshTimer;

  List<Notification> get notifications => _notifications;
  List<Notification> get unreadNotifications => _unreadNotifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  NotificationProvider() {
    // Check if user is authenticated before initializing
    _initializeIfAuthenticated();
    
    // Set up a timer to refresh notifications every 3 minutes instead of 30 seconds
    // This reduces server load and battery consumption
    _refreshTimer = Timer.periodic(Duration(minutes: 3), (timer) {
      _initializeIfAuthenticated(silent: true);
    });
  }
  
  Future<void> _initializeIfAuthenticated({bool silent = false}) async {
    bool isLoggedIn = await AuthUtils.isLoggedIn();
    if (isLoggedIn) {
      fetchNotifications(silent: silent);
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Track when the last fetch occurred to prevent excessive API calls
  DateTime _lastFetchTime = DateTime.now().subtract(Duration(minutes: 5));
  bool _isFetchInProgress = false;
  
  Future<void> fetchNotifications({bool silent = false}) async {
    // Don't allow concurrent fetches
    if (_isFetchInProgress) {
      return;
    }
    
    // Don't fetch more often than once every 30 seconds unless explicitly requested
    final now = DateTime.now();
    if (silent && now.difference(_lastFetchTime).inSeconds < 30) {
      return;
    }
    
    _isFetchInProgress = true;
    
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      // Fetch all notifications in a single API call
      _notifications = await _notificationService.getUserNotifications();
      
      // Filter unread notifications from the fetched list instead of making a separate API call
      _unreadNotifications = _notifications.where((notification) => !notification.isRead).toList();
      
      // Update unread count
      _unreadCount = _unreadNotifications.length;
      
      // Update last fetch time
      _lastFetchTime = now;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      print('Error fetching notifications: $e');
    } finally {
      _isFetchInProgress = false;
      if (!silent) notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final success = await _notificationService.markAsRead(notificationId);
    
    if (success) {
      // Update local state
      _notifications = _notifications.map((notification) {
        if (notification.id == notificationId) {
          return Notification(
            id: notification.id,
            title: notification.title,
            message: notification.message,
            type: notification.type,
            relatedNoteId: notification.relatedNoteId,
            isRead: true,
            createdAt: notification.createdAt,
          );
        }
        return notification;
      }).toList();
      
      // Update unread notifications
      _unreadNotifications = _unreadNotifications
          .where((notification) => notification.id != notificationId)
          .toList();
      
      // Update unread count
      _unreadCount = _unreadNotifications.length;
      
      notifyListeners();
    } else {
      print('Failed to mark notification as read');
    }
  }

  Future<void> markAllAsRead() async {
    final success = await _notificationService.markAllAsRead();
    
    if (success) {
      // Update local state
      _notifications = _notifications.map((notification) {
        return Notification(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          relatedNoteId: notification.relatedNoteId,
          isRead: true,
          createdAt: notification.createdAt,
        );
      }).toList();
      
      // Clear unread notifications
      _unreadNotifications = [];
      
      // Update unread count
      _unreadCount = 0;
      
      notifyListeners();
    } else {
      print('Failed to mark all notifications as read');
    }
  }
}
