import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/config/env.dart';
import 'package:frontend/models/lockout_note.dart';
import 'package:frontend/models/user.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiService() {
    _dio.options.baseUrl = Env.apiBaseUrl;
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            print('Adding token to request: Bearer ${token.substring(0, 10)}...');
            
            // Print request details for debugging
            print('Request: ${options.method} ${options.path}');
            print('Headers: ${options.headers}');
          } else {
            print('No token found for request: ${options.method} ${options.path}');
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          print('API Error: ${error.response?.statusCode} - ${error.message}');
          if (error.response?.data != null) {
            print('Error response data: ${error.response?.data}');
          }
          
          if (error.response?.statusCode == 401) {
            print('Authentication error: Token might be expired or invalid');
          } else if (error.response?.statusCode == 403) {
            print('Authorization error: User does not have required permissions');
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Expose the Dio instance for other services to use
  Dio getDio() {
    return _dio;
  }

  // Authentication
  Future<Map<String, dynamic>> login(String matricule, String password) async {
    try {
      print('==== LOGIN ATTEMPT ====');
      print('Attempting login with matricule: $matricule');
      print('Current API Base URL: ${_dio.options.baseUrl}');
      
      // For Android emulator, ensure we're using the correct IP to connect to the host machine
      if (!_dio.options.baseUrl.contains('10.0.2.2')) {
        print('Updating API Base URL for Android emulator');
        _dio.options.baseUrl = 'http://10.0.2.2:8080';
      }
      print('Using API Base URL: ${_dio.options.baseUrl}');
      
      // Add detailed logging for the request
      print('Preparing login request with data:');
      print('Matricule: $matricule');
      print('Password: ${password.replaceAll(RegExp(r'.'), '*')}');
      
      try {
        print('Sending login request to: ${_dio.options.baseUrl}/api/auth/login');
        final response = await _dio.post(
          '/api/auth/login',
          data: {
            'matricule': matricule,
            'password': password,
          },
          options: Options(
            validateStatus: (status) => true,
            headers: {
              'Content-Type': 'application/json',
            },
            receiveTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 10),
          ),
        );
        
        print('Login response received');
        print('Login response status: ${response.statusCode}');
        print('Login response headers: ${response.headers}');
        
        // Safely print response data if it exists
        if (response.data != null) {
          print('Login response data: ${response.data}');
        } else {
          print('Login response data is null');
        }
        
        if (response.statusCode != 200) {
          print('Login failed with status: ${response.statusCode}');
          if (response.data != null) {
            print('Response data: ${response.data}');
          }
          throw Exception('Login failed with status code: ${response.statusCode}');
        }
        
        // Check if token exists in response
        if (response.data == null || response.data is! Map<String, dynamic>) {
          print('Invalid response format: data is null or not a map');
          throw Exception('Invalid response format: data is null or not a map');
        }
        
        final token = response.data['token'];
        if (token == null) {
          print('Token is null in response data: ${response.data}');
          throw Exception('Invalid response format: token is missing');
        }
        
        // Store the JWT token
        await _secureStorage.write(key: 'jwt_token', value: token);
        
        // Store the user data for role-based access control
        await _secureStorage.write(key: 'user_data', value: jsonEncode({
          'id': response.data['id'],
          'matricule': response.data['matricule'],
          'email': response.data['email'],
          'role': response.data['role'],
        }));
        
        print('Login successful, token and user data stored');
        
        return response.data;
      } catch (requestError) {
        print('Error during login request: $requestError');
        // No fallback to mock authentication - we want to use the real backend
        rethrow;
      }
    } catch (e) {
      print('==== LOGIN ERROR ====');
      print('Login error: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'jwt_token');
  }

  Future<User> register(String matricule, String email, String password, String role) async {
    try {
      print('Registering user: $matricule, $email, $role');
      final response = await _dio.post(
        '/api/auth/register',
        data: {
          'matricule': matricule,
          'email': email,
          'password': password,
          'role': role,
        },
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      print('Register response status: ${response.statusCode}');
      print('Register response data: ${response.data}');
      
      if (response.statusCode != 200) {
        String errorMessage = 'Registration failed';
        if (response.data is Map && response.data.containsKey('error')) {
          errorMessage = response.data['error'];
        }
        throw Exception(errorMessage);
      }
      
      return User.fromJson(response.data);
    } catch (e) {
      print('Register error: $e');
      rethrow;
    }
  }
  
  // Get all users - only accessible to admin users
  Future<List<User>> getAllUsers() async {
    try {
      final response = await _dio.get('/api/auth/users');
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => User.fromJson(json))
            .toList();
      } else {
        // If the response is not a list, it might be an error or a different format
        print('Unexpected response format: ${response.data}');
        return [];
      }
    } catch (e) {
      print('Error getting users: $e');
      rethrow;
    }
  }

  // Lockout Notes
  Future<List<LockoutNote>> getAllNotes() async {
    try {
      final response = await _dio.get('/api/notes');
      
      return (response.data as List)
          .map((json) => LockoutNote.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LockoutNote>> getNotesByStatus(NoteStatus status) async {
    try {
      final response = await _dio.get('/api/notes/status/${status.toString().split('.').last}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => LockoutNote.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notes');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Assign a note to a Charge Consignation user
  Future<LockoutNote> assignNote(String id, int assignedToUserId) async {
    try {
      final response = await _dio.put(
        '/api/notes/$id/assign',
        data: {
          'assignedToUserId': assignedToUserId,
        },
      );
      
      return LockoutNote.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<LockoutNote> getNoteById(String id) async {
    try {
      final response = await _dio.get('/api/notes/$id');
      
      return LockoutNote.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<LockoutNote> createNote(String posteHt, {
    EquipmentType? equipmentType,
    String? equipmentDetails,
    String? uniteSteg,
    String? workNature,
    DateTime? retraitDate,
    DateTime? debutTravaux,
    DateTime? finTravaux,
    DateTime? retourDate,
    int? joursIndisponibilite,
    String? chargeRetrait,
    String? chargeConsignation,
    String? chargeTravaux,
    String? chargeEssais,
    String? instructionsTechniques,
    String? destinataires,
    String? coupureDemandeePar,
    String? noteTransmiseA,
  }) async {
    try {
      // First check if user is authenticated
      String? token = await _secureStorage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception('Not authenticated. Please log in again.');
      }
      
      // Print token info for debugging
      print('Creating note with token: ${token.substring(0, 10)}...');
      
      // Try to decode the JWT token to check the role
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          // Decode the payload
          String normalizedPayload = base64Url.normalize(parts[1]);
          String decodedPayload = utf8.decode(base64Url.decode(normalizedPayload));
          Map<String, dynamic> payload = jsonDecode(decodedPayload);
          print('Token payload: $payload');
          
          // Check if the role is present
          if (payload.containsKey('role')) {
            print('User role from token: ${payload['role']}');
          } else {
            print('No role found in token');
          }
        }
      } catch (e) {
        print('Error decoding token: $e');
      }
      
      // Prepare request data, ensuring proper types
      final data = {
        'posteHt': posteHt.trim(),
        // Send the equipment type as enum name with underscores
        'equipmentType': equipmentType != null ? equipmentType.name : null,
        'equipmentDetails': equipmentDetails?.trim(),
        'uniteSteg': uniteSteg?.trim(),
        'workNature': workNature?.trim(),
        'retraitDate': retraitDate?.toIso8601String(),
        'debutTravaux': debutTravaux?.toIso8601String(),
        'finTravaux': finTravaux?.toIso8601String(),
        'retourDate': retourDate?.toIso8601String(),
        'joursIndisponibilite': joursIndisponibilite?.toString(),
        'chargeRetrait': chargeRetrait?.trim(),
        'chargeConsignation': chargeConsignation?.trim(),
        'chargeTravaux': chargeTravaux?.trim(),
        'chargeEssais': chargeEssais?.trim(),
        'instructionsTechniques': instructionsTechniques?.trim(),
        'destinataires': destinataires?.trim(),
        'coupureDemandeePar': coupureDemandeePar?.trim(),
        'noteTransmiseA': noteTransmiseA?.trim(),
      };
      
      // Remove null values to avoid backend validation issues
      data.removeWhere((key, value) => value == null);
      
      print('Sending note creation request with data: $data');
      
      try {
        // Try with explicit content type header
        final response = await _dio.post(
          '/api/notes',
          data: data,
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            validateStatus: (status) => status! < 500, // Allow 4xx responses to be handled
          ),
        );
        
        print('Note creation response: ${response.statusCode} - ${response.data}');
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          print('Note created successfully');
          return LockoutNote.fromJson(response.data);
        } else if (response.statusCode == 403) {
          print('Permission denied error');
          // Try to extract more detailed error message if available
          String errorMsg = 'Permission denied';
          if (response.data is Map && response.data.containsKey('message')) {
            errorMsg = response.data['message'];
          }
          throw Exception('Permission denied: $errorMsg. You may not have the required role to create notes.');
        } else if (response.statusCode == 400) {
          print('Bad request error');
          String errorMsg = 'Invalid request';
          if (response.data is Map) {
            if (response.data.containsKey('error')) {
              errorMsg = response.data['error'];
            } else if (response.data.containsKey('message')) {
              errorMsg = response.data['message'];
            }
          }
          throw Exception('Bad request: $errorMsg');
        } else {
          print('Other error: ${response.statusCode}');
          throw Exception('Failed to create note: Status code ${response.statusCode}');
        }
      } catch (e) {
        print('Exception during note creation: $e');
        if (e is DioException) {
          print('DioException: ${e.type} - ${e.message}');
          if (e.response != null) {
            print('Response status: ${e.response?.statusCode}');
            print('Response data: ${e.response?.data}');
          }
          
          if (e.response?.statusCode == 403) {
            // Try to extract more detailed error message if available
            String errorMsg = 'Permission denied';
            if (e.response?.data is Map && e.response?.data.containsKey('message')) {
              errorMsg = e.response?.data['message'];
            }
            throw Exception('Permission denied: $errorMsg. You may not have the required role to create notes.');
          } else if (e.response?.statusCode == 400) {
            String errorMsg = 'Invalid request';
            if (e.response?.data is Map) {
              if (e.response?.data.containsKey('error')) {
                errorMsg = e.response?.data['error'];
              } else if (e.response?.data.containsKey('message')) {
                errorMsg = e.response?.data['message'];
              }
            }
            throw Exception('Bad request: $errorMsg');
          }
        }
        throw Exception('Failed to create note: ${e.toString()}');
      }
    } catch (e) {
      print('Error creating note: $e');
      rethrow;
    }
  }
  
  Future<LockoutNote> updateNote(String id, {
    String? posteHt,
    EquipmentType? equipmentType,
    String? equipmentDetails,
    String? uniteSteg,
    String? workNature,
    DateTime? retraitDate,
    DateTime? debutTravaux,
    DateTime? finTravaux,
    DateTime? retourDate,
    int? joursIndisponibilite,
    String? chargeRetrait,
    String? chargeConsignation,
    String? chargeTravaux,
    String? chargeEssais,
    String? instructionsTechniques,
    String? destinataires,
    String? coupureDemandeePar,
    String? noteTransmiseA,
    String? rejectionReason,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (posteHt != null) data['posteHt'] = posteHt.trim();
      if (equipmentType != null) data['equipmentType'] = equipmentType.name;
      if (equipmentDetails != null) data['equipmentDetails'] = equipmentDetails.trim();
      if (uniteSteg != null) data['uniteSteg'] = uniteSteg.trim();
      if (workNature != null) data['workNature'] = workNature.trim();
      if (retraitDate != null) data['retraitDate'] = retraitDate.toIso8601String();
      if (debutTravaux != null) data['debutTravaux'] = debutTravaux.toIso8601String();
      if (finTravaux != null) data['finTravaux'] = finTravaux.toIso8601String();
      if (retourDate != null) data['retourDate'] = retourDate.toIso8601String();
      if (joursIndisponibilite != null) data['joursIndisponibilite'] = joursIndisponibilite.toString();
      if (chargeRetrait != null) data['chargeRetrait'] = chargeRetrait.trim();
      if (chargeConsignation != null) data['chargeConsignation'] = chargeConsignation.trim();
      if (chargeTravaux != null) data['chargeTravaux'] = chargeTravaux.trim();
      if (chargeEssais != null) data['chargeEssais'] = chargeEssais.trim();
      if (instructionsTechniques != null) data['instructionsTechniques'] = instructionsTechniques.trim();
      if (destinataires != null) data['destinataires'] = destinataires.trim();
      if (coupureDemandeePar != null) data['coupureDemandeePar'] = coupureDemandeePar.trim();
      if (noteTransmiseA != null) data['noteTransmiseA'] = noteTransmiseA.trim();
      if (rejectionReason != null) data['rejectionReason'] = rejectionReason.trim();
      
      final response = await _dio.put(
        '/api/notes/$id',
        data: data,
      );
      
      return LockoutNote.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<LockoutNote> validateNote(String id, NoteStatus status, {
    String? rejectionReason,
    // Additional fields that might be updated during validation
    EquipmentType? equipmentType,
    String? equipmentDetails,
    String? uniteSteg,
    String? workNature,
    DateTime? retraitDate,
    DateTime? debutTravaux,
    DateTime? finTravaux,
    DateTime? retourDate,
    int? joursIndisponibilite,
    String? chargeRetrait,
    String? chargeConsignation,
    String? chargeTravaux,
    String? chargeEssais,
    String? instructionsTechniques,
    String? destinataires,
    String? coupureDemandeePar,
    String? noteTransmiseA,
  }) async {
    try {
      final data = {
        'status': status.toString().split('.').last,
      };
      
      // Add rejection reason if provided and status is REJECTED
      if (status == NoteStatus.REJECTED && rejectionReason != null) {
        data['rejectionReason'] = rejectionReason;
      }
      
      // For debugging
      print('Validating note with status: ${status.toString()} and data: $data');
      
      // Add any other fields that might be updated during validation
      if (equipmentType != null) {
        data['equipmentType'] = equipmentType.name;
      }
      
      if (equipmentDetails != null) {
        data['equipmentDetails'] = equipmentDetails.trim();
      }
      
      if (uniteSteg != null) {
        data['uniteSteg'] = uniteSteg.trim();
      }
      
      if (workNature != null) {
        data['workNature'] = workNature.trim();
      }
      
      if (retraitDate != null) {
        data['retraitDate'] = retraitDate.toIso8601String();
      }
      
      if (debutTravaux != null) {
        data['debutTravaux'] = debutTravaux.toIso8601String();
      }
      
      if (finTravaux != null) {
        data['finTravaux'] = finTravaux.toIso8601String();
      }
      
      if (retourDate != null) {
        data['retourDate'] = retourDate.toIso8601String();
      }
      
      if (joursIndisponibilite != null) {
        data['joursIndisponibilite'] = joursIndisponibilite.toString();
      }
      
      if (chargeRetrait != null) {
        data['chargeRetrait'] = chargeRetrait.trim();
      }
      
      if (chargeConsignation != null) {
        data['chargeConsignation'] = chargeConsignation.trim();
      }
      
      if (chargeTravaux != null) {
        data['chargeTravaux'] = chargeTravaux.trim();
      }
      
      if (chargeEssais != null) {
        data['chargeEssais'] = chargeEssais.trim();
      }
      
      if (instructionsTechniques != null) {
        data['instructionsTechniques'] = instructionsTechniques.trim();
      }
      
      if (destinataires != null) {
        data['destinataires'] = destinataires.trim();
      }
      
      if (coupureDemandeePar != null) {
        data['coupureDemandeePar'] = coupureDemandeePar.trim();
      }
      
      if (noteTransmiseA != null) {
        data['noteTransmiseA'] = noteTransmiseA.trim();
      }
      
      final response = await _dio.put(
        '/api/notes/$id/validate',
        data: data,
      );
      
      return LockoutNote.fromJson(response.data);
    } catch (e) {
      print('Exception during note validation: $e');
      if (e is DioException) {
        print('DioException: ${e.type} - ${e.message}');
        if (e.response != null) {
          print('Response status: ${e.response?.statusCode}');
          print('Response data: ${e.response?.data}');
        }
        
        if (e.response?.statusCode == 403) {
          String errorMsg = 'Permission denied';
          if (e.response?.data is Map && e.response?.data.containsKey('message')) {
            errorMsg = e.response?.data['message'];
          }
          throw Exception('Permission denied: $errorMsg. You may not have the required role to validate notes.');
        } else if (e.response?.statusCode == 400) {
          String errorMsg = 'Invalid request';
          if (e.response?.data is Map) {
            if (e.response?.data.containsKey('error')) {
              errorMsg = e.response?.data['error'];
            } else if (e.response?.data.containsKey('message')) {
              errorMsg = e.response?.data['message'];
            }
          }
          throw Exception('Bad request: $errorMsg');
        }
      }
      throw Exception('Failed to validate note: ${e.toString()}');
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _dio.delete('/api/notes/$id');
    } catch (e) {
      rethrow;
    }
  }
  
  // New methods for the enhanced workflow
  
  // Start the consignation process
  Future<LockoutNote> startConsignation(String id) async {
    try {
      final response = await _dio.put(
        '/api/notes/$id/consignation/start',
        data: {},
      );
      
      return LockoutNote.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Complete the consignation process
  Future<LockoutNote> completeConsignation(String id) async {
    try {
      final response = await _dio.put(
        '/api/notes/$id/consignation/complete',
        data: {},
      );
      
      return LockoutNote.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Start the deconsignation process
  Future<LockoutNote> startDeconsignation(String id) async {
    try {
      final response = await _dio.put(
        '/api/notes/$id/deconsignation/start',
        data: {},
      );
      
      return LockoutNote.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Complete the deconsignation process
  Future<LockoutNote> completeDeconsignation(String id) async {
    try {
      final response = await _dio.put(
        '/api/notes/$id/deconsignation/complete',
        data: {},
      );
      
      return LockoutNote.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Test connection between frontend, backend, and database
  Future<Map<String, dynamic>> testConnection() async {
    try {
      print('==== TESTING CONNECTION ====');
      print('Current API Base URL: ${_dio.options.baseUrl}');
      
      // Update the API URL to use the correct port and IP for the backend
      // For Android emulator, use 10.0.2.2 to connect to the host machine
      _dio.options.baseUrl = 'http://10.0.2.2:8080';
      print('Updated API Base URL: ${_dio.options.baseUrl}');
      
      print('Sending test request to: ${_dio.options.baseUrl}/api/test/connection/status');
      final response = await _dio.get(
        '/api/test/connection/status',
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      
      print('Test response status: ${response.statusCode}');
      if (response.data != null) {
        print('Test response data: ${response.data}');
      } else {
        print('Test response data is null');
      }
      
      if (response.statusCode != 200) {
        throw Exception('Connection test failed with status code: ${response.statusCode}');
      }
      
      return response.data;
    } catch (e) {
      print('Connection test error: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }
}
