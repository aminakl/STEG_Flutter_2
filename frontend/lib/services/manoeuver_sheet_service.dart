import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../utils/auth_utils.dart';
import '../models/manoeuver_sheet.dart';

class ManoeuverSheetService {
  final Dio _dio = Dio();
  final String baseUrl = ApiConfig.baseUrl;

  Future<ManoeuverSheet> createManoeuverSheet(String lockoutNoteId) async {
    try {
      String? token = await AuthUtils.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await _dio.post(
        '$baseUrl/api/manoeuver-sheets/$lockoutNoteId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return ManoeuverSheet.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<ManoeuverSheet> verifyEPI(String manoeuverSheetId) async {
    try {
      String? token = await AuthUtils.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await _dio.put(
        '$baseUrl/api/manoeuver-sheets/$manoeuverSheetId/verify-epi',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return ManoeuverSheet.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<ManoeuverSheet> startConsignation(String manoeuverSheetId) async {
    try {
      String? token = await AuthUtils.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await _dio.put(
        '$baseUrl/api/manoeuver-sheets/$manoeuverSheetId/start-consignation',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return ManoeuverSheet.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<ManoeuverSheet> completeConsignation(String manoeuverSheetId) async {
    try {
      String? token = await AuthUtils.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await _dio.put(
        '$baseUrl/api/manoeuver-sheets/$manoeuverSheetId/complete-consignation',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return ManoeuverSheet.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<ManoeuverSheet> startDeconsignation(String manoeuverSheetId) async {
    try {
      String? token = await AuthUtils.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await _dio.put(
        '$baseUrl/api/manoeuver-sheets/$manoeuverSheetId/start-deconsignation',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return ManoeuverSheet.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<ManoeuverSheet> completeDeconsignation(String manoeuverSheetId) async {
    try {
      String? token = await AuthUtils.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await _dio.put(
        '$baseUrl/api/manoeuver-sheets/$manoeuverSheetId/complete-deconsignation',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return ManoeuverSheet.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<ManoeuverSheet> getManoeuverSheet(String manoeuverSheetId) async {
    try {
      String? token = await AuthUtils.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await _dio.get(
        '$baseUrl/api/manoeuver-sheets/$manoeuverSheetId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return ManoeuverSheet.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<ManoeuverSheet> getManoeuverSheetByLockoutNoteId(String lockoutNoteId) async {
    try {
      String? token = await AuthUtils.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await _dio.get(
        '$baseUrl/api/manoeuver-sheets/by-lockout-note/$lockoutNoteId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return ManoeuverSheet.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reportIncident(String manoeuverSheetId, String description) async {
    try {
      String? token = await AuthUtils.getToken();
      if (token == null) throw Exception('Not authenticated');

      await _dio.post(
        '$baseUrl/api/manoeuver-sheets/$manoeuverSheetId/report-incident',
        data: {
          'description': description,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
} 