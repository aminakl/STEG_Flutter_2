import 'package:dio/dio.dart';
import '../utils/api_config.dart';
import '../utils/auth_utils.dart';

class WorkAttestationService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  Future<String> createWorkAttestation({
    required String manoeuverSheetId,
    required String workId,
    required String workerId,
    required List<String> equipmentTypes,
  }) async {
    final token = await AuthUtils.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final response = await _dio.post(
        '/api/work-attestations',
        data: {
          'manoeuverSheetId': manoeuverSheetId,
          'workId': workId,
          'workerId': workerId,
          'equipmentTypes': equipmentTypes,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.data['id'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create work attestation');
    }
  }

  Future<Map<String, dynamic>> getWorkAttestation(String id) async {
    final token = await AuthUtils.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final response = await _dio.get(
        '/api/work-attestations/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get work attestation');
    }
  }
} 