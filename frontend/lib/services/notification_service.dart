import 'package:dio/dio.dart';
import '../models/notification.dart';
import '../config/api_config.dart';
import '../utils/auth_utils.dart';
import 'api_service.dart';

class NotificationService {
  final Dio _dio;
  final String baseUrl = ApiConfig.baseUrl; // Use the dynamic API config
  
  NotificationService() : _dio = ApiService().getDio();

  // Cache for notifications to reduce API calls
  List<Notification> _cachedNotifications = [];
  DateTime _lastNotificationFetchTime = DateTime.fromMillisecondsSinceEpoch(0);
  
  Future<List<Notification>> getUserNotifications() async {
    try {
      bool isLoggedIn = await AuthUtils.isLoggedIn();
      if (!isLoggedIn) {
        return [];
      }
      
      // Use cached data if it's less than 1 minute old
      final now = DateTime.now();
      if (_cachedNotifications.isNotEmpty && 
          now.difference(_lastNotificationFetchTime).inSeconds < 60) {
        return _cachedNotifications;
      }
      
      final response = await _dio.get(
        '$baseUrl/api/notifications',
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        _cachedNotifications = data.map((item) => Notification.fromJson(item)).toList();
        _lastNotificationFetchTime = now;
        return _cachedNotifications;
      } else {
        print('Failed to load notifications: ${response.statusCode}');
        // Return cached data if available, otherwise empty list
        return _cachedNotifications.isNotEmpty ? _cachedNotifications : [];
      }
    } catch (e) {
      if (e.toString().contains('Not authenticated')) {
        // Silently return empty list for auth errors
        return [];
      }
      print('Error fetching notifications: $e');
      // Return cached data if available, otherwise empty list
      return _cachedNotifications.isNotEmpty ? _cachedNotifications : [];
    }
  }

  // Flag to use cached notifications instead of making a separate API call
  bool _useClientSideFiltering = true;
  
  Future<List<Notification>> getUnreadNotifications() async {
    try {
      bool isLoggedIn = await AuthUtils.isLoggedIn();
      if (!isLoggedIn) {
        return [];
      }
      
      // If client-side filtering is enabled, use the cached notifications
      if (_useClientSideFiltering && _cachedNotifications.isNotEmpty) {
        return _cachedNotifications.where((notification) => !notification.isRead).toList();
      }
      
      final response = await _dio.get(
        '$baseUrl/api/notifications/unread',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => Notification.fromJson(item)).toList();
      } else {
        print('Failed to load unread notifications: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      if (e.toString().contains('Not authenticated')) {
        // Silently return empty list for auth errors
        return [];
      }
      print('Error fetching unread notifications: $e');
      return [];
    }
  }

  Future<int> getUnreadCount() async {
    try {
      bool isLoggedIn = await AuthUtils.isLoggedIn();
      if (!isLoggedIn) {
        return 0;
      }
      
      try {
        final response = await _dio.get(
          '$baseUrl/api/notifications/count',
          options: Options(
            receiveTimeout: const Duration(seconds: 3),
            sendTimeout: const Duration(seconds: 3),
          ),
        );

        if (response.statusCode == 200) {
          return response.data;
        } else {
          print('Failed to get unread count: ${response.statusCode}');
          return 0;
        }
      } catch (e) {
        if (e.toString().contains('Not authenticated')) {
          // Silently handle auth errors
          return 0;
        }
        print('Error getting unread count: $e');
        return 0;
      }
    } catch (e) {
      print('Authentication error: $e');
      return 0;
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      bool isLoggedIn = await AuthUtils.isLoggedIn();
      if (!isLoggedIn) {
        return false;
      }
      
      try {
        final response = await _dio.put(
          '$baseUrl/api/notifications/$notificationId/read',
          options: Options(
            receiveTimeout: const Duration(seconds: 3),
            sendTimeout: const Duration(seconds: 3),
          ),
        );

        if (response.statusCode == 200) {
          return true;
        } else {
          print('Failed to mark notification as read: ${response.statusCode}');
          return false;
        }
      } catch (e) {
        if (e.toString().contains('Not authenticated')) {
          // Silently handle auth errors
          return false;
        }
        print('Error marking notification as read: $e');
        return false;
      }
    } catch (e) {
      print('Authentication error: $e');
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      bool isLoggedIn = await AuthUtils.isLoggedIn();
      if (!isLoggedIn) {
        return false;
      }
      
      try {
        final response = await _dio.put(
          '$baseUrl/api/notifications/read-all',
          options: Options(
            receiveTimeout: const Duration(seconds: 3),
            sendTimeout: const Duration(seconds: 3),
          ),
        );

        if (response.statusCode == 200) {
          return true;
        } else {
          print('Failed to mark all notifications as read: ${response.statusCode}');
          return false;
        }
      } catch (e) {
        if (e.toString().contains('Not authenticated')) {
          // Silently handle auth errors
          return false;
        }
        print('Error marking all notifications as read: $e');
        return false;
      }
    } catch (e) {
      print('Authentication error: $e');
      return false;
    }
  }
}
