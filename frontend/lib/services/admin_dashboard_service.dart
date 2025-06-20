import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../utils/auth_utils.dart';

class AdminDashboardService {
  final Dio _dio = Dio();
  final String baseUrl = ApiConfig.baseUrl;

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      String? token = await AuthUtils.getToken();
      if (token == null) throw Exception('Not authenticated');
      
      final response = await _dio.get(
        '$baseUrl/api/admin/dashboard/stats',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        print('Server returned error code: ${response.statusCode}');
        // Return empty data with the correct structure instead of mock data
        return {
          'totalNotes': 0,
          'notesLast30Days': 0,
          'notesByStatus': {
            'DRAFT': 0,
            'PENDING_CHEF_BASE': 0,
            'PENDING_CHARGE_EXPLOITATION': 0,
            'VALIDATED': 0,
            'REJECTED': 0
          },
          'usersByRole': {
            'ADMIN': 0,
            'CHEF_EXPLOITATION': 0,
            'CHEF_DE_BASE': 0,
            'CHARGE_EXPLOITATION': 0,
            'CHARGE_CONSIGNATION': 0
          }
        };
      }
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      // Return empty data with the correct structure
      return {
        'totalNotes': 0,
        'notesLast30Days': 0,
        'notesByStatus': {
          'DRAFT': 0,
          'PENDING_CHEF_BASE': 0,
          'PENDING_CHARGE_EXPLOITATION': 0,
          'VALIDATED': 0,
          'REJECTED': 0
        },
        'usersByRole': {
          'ADMIN': 0,
          'CHEF_EXPLOITATION': 0,
          'CHEF_DE_BASE': 0,
          'CHARGE_EXPLOITATION': 0,
          'CHARGE_CONSIGNATION': 0
        }
      };
    }
  }

  Future<Map<String, dynamic>> getMonthlyStats() async {
    try {
      String? token = await AuthUtils.getToken();
      if (token == null) throw Exception('Not authenticated');
      final response = await _dio.get(
        '$baseUrl/api/admin/dashboard/monthly-stats',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        print('Server returned error code: ${response.statusCode}');
        // Return empty data with the correct structure
        return {
          'months': [],
          'noteCounts': [],
          'validationRates': []
        };
      }
    } catch (e) {
      print('Error fetching monthly stats: $e');
      // Return empty data with the correct structure
      return {
        'months': [],
        'noteCounts': [],
        'validationRates': []
      };
    }
  }

  Future<Map<String, dynamic>> getUserPerformance() async {
    try {
      String? token = await AuthUtils.getToken();
      if (token == null) throw Exception('Not authenticated');
      final response = await _dio.get(
        '$baseUrl/api/admin/dashboard/user-performance',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        print('Server returned error code: ${response.statusCode}');
        // Return empty data with the correct structure
        return {
          'users': [],
          'notesCounts': [],
          'validationTimes': []
        };
      }
    } catch (e) {
      print('Error fetching user performance data: $e');
      // Return empty data with the correct structure
      return {
        'users': [],
        'notesCounts': [],
        'validationTimes': []
      };
    }
  }
}
