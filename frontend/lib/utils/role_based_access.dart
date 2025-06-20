import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class RoleBasedAccess {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  // Role constants
  static const String ROLE_ADMIN = 'ADMIN';
  static const String ROLE_CHEF_EXPLOITATION = 'CHEF_EXPLOITATION';
  static const String ROLE_CHEF_DE_BASE = 'CHEF_DE_BASE';
  static const String ROLE_CHARGE_EXPLOITATION = 'CHARGE_EXPLOITATION';
  static const String ROLE_CHARGE_CONSIGNATION = 'CHARGE_CONSIGNATION';
  
  // Get the current user's role from secure storage
  static Future<String?> getCurrentUserRole() async {
    final userData = await _secureStorage.read(key: 'user_data');
    if (userData != null) {
      final Map<String, dynamic> user = jsonDecode(userData);
      return user['role'];
    }
    return null;
  }
  
  // Check if the current user has admin access
  static Future<bool> isAdmin() async {
    final role = await getCurrentUserRole();
    return role == ROLE_ADMIN;
  }
  
  // Check if the current user has chef d'exploitation access
  static Future<bool> isChefExploitation() async {
    final role = await getCurrentUserRole();
    return role == ROLE_CHEF_EXPLOITATION;
  }
  
  // Check if the current user has chef de base access
  static Future<bool> isChefDeBase() async {
    final role = await getCurrentUserRole();
    return role == ROLE_CHEF_DE_BASE;
  }
  
  // Check if the current user has chargé d'exploitation access
  static Future<bool> isChargeExploitation() async {
    final role = await getCurrentUserRole();
    return role == ROLE_CHARGE_EXPLOITATION;
  }
  
  // Check if the current user has chargé de consignation access
  static Future<bool> isChargeConsignation() async {
    final role = await getCurrentUserRole();
    return role == ROLE_CHARGE_CONSIGNATION;
  }
  
  // Check if the current user can validate notes as Chef de Base
  static Future<bool> canValidateAsChefDeBase() async {
    final role = await getCurrentUserRole();
    return role == ROLE_ADMIN || role == ROLE_CHEF_DE_BASE;
  }
  
  // Check if the current user can validate notes as Charge Exploitation
  static Future<bool> canValidateAsChargeExploitation() async {
    final role = await getCurrentUserRole();
    return role == ROLE_ADMIN || role == ROLE_CHARGE_EXPLOITATION;
  }
  
  // Check if the current user can submit notes for validation
  static Future<bool> canSubmitForValidation() async {
    final role = await getCurrentUserRole();
    return role == ROLE_ADMIN || role == ROLE_CHEF_EXPLOITATION;
  }
  
  // Check if the current user can delete notes
  static Future<bool> canDeleteNotes() async {
    final role = await getCurrentUserRole();
    return role == ROLE_ADMIN;
  }
  
  // Check if the current user can register new users
  static Future<bool> canRegisterUsers() async {
    final role = await getCurrentUserRole();
    return role == ROLE_ADMIN;
  }
  
  // Check if the current user can create notes
  static Future<bool> canCreateNotes() async {
    final role = await getCurrentUserRole();
    // Only Chef d'exploitation can create notes
    return role == ROLE_ADMIN || role == ROLE_CHEF_EXPLOITATION;
  }
  
  // Check if the current user can update notes
  static Future<bool> canUpdateNotes() async {
    final role = await getCurrentUserRole();
    // Only the creator or admin can update notes
    return role == ROLE_ADMIN || role == ROLE_CHEF_EXPLOITATION;
  }
  
  // Check if the current user can assign notes to Charge Consignation
  static Future<bool> canAssignNotes() async {
    final role = await getCurrentUserRole();
    return role == ROLE_ADMIN || role == ROLE_CHARGE_EXPLOITATION;
  }
  
  // Check if the current user can perform consignation
  static Future<bool> canPerformConsignation() async {
    final role = await getCurrentUserRole();
    return role == ROLE_ADMIN || role == ROLE_CHARGE_CONSIGNATION;
  }
  
  // Check if the current user can perform deconsignation
  static Future<bool> canPerformDeconsignation() async {
    final role = await getCurrentUserRole();
    return role == ROLE_ADMIN || role == ROLE_CHARGE_CONSIGNATION;
  }
  
  // Check if the current user can access the admin dashboard
  static Future<bool> canAccessDashboard() async {
    final role = await getCurrentUserRole();
    return role == ROLE_ADMIN || role == ROLE_CHEF_EXPLOITATION || role == ROLE_CHEF_DE_BASE;
  }
  
  // Check if the current user can validate notes (either as Chef de Base or Charge Exploitation)
  static Future<bool> canValidateNotes() async {
    final role = await getCurrentUserRole();
    return role == ROLE_ADMIN || role == ROLE_CHEF_DE_BASE || role == ROLE_CHARGE_EXPLOITATION;
  }
}
