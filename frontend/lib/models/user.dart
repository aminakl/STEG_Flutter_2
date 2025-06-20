class User {
  final String id;
  final String matricule;
  final String name;
  final String role;
  final String? email;
  final String? phone;
  final bool isActive;
  
  // Role constants
  static const String ROLE_ADMIN = 'ADMIN';
  static const String ROLE_CHEF_EXPLOITATION = 'CHEF_EXPLOITATION';
  static const String ROLE_CHEF_DE_BASE = 'CHEF_DE_BASE';
  static const String ROLE_CHARGE_EXPLOITATION = 'CHARGE_EXPLOITATION';
  static const String ROLE_CHARGE_CONSIGNATION = 'CHARGE_CONSIGNATION';

  User({
    required this.id,
    required this.matricule,
    required this.name,
    required this.role,
    this.email,
    this.phone,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing user from JSON: $json');
      // Handle different ID formats (int, string, or null)
      int userId = 0;
      if (json['id'] != null) {
        if (json['id'] is int) {
          userId = json['id'];
        } else {
          try {
            userId = int.parse(json['id'].toString());
          } catch (e) {
            print('Could not parse ID: ${json['id']}');
          }
        }
      }
      
      return User(
        id: userId.toString(),
        matricule: json['matricule'] ?? '',
        name: json['name'] ?? '',
        role: json['role'] ?? '',
        email: json['email'],
        phone: json['phone'],
        isActive: json['isActive'] ?? json['is_active'] ?? true,
      );
    } catch (e) {
      print('Error parsing User: $e');
      print('JSON data: $json');
      // Return a default user in case of parsing error
      return User(
        id: '0',
        matricule: 'Error',
        name: 'Error',
        role: 'ERROR',
        email: null,
        phone: null,
        isActive: false,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matricule': matricule,
      'name': name,
      'role': role,
      'email': email,
      'phone': phone,
      'isActive': isActive,
    };
  }
  
  // Helper methods for role checking
  bool isAdmin() => role == ROLE_ADMIN;
  
  bool isChefExploitation() => role == ROLE_CHEF_EXPLOITATION;
  
  bool isChefDeBase() => role == ROLE_CHEF_DE_BASE;
  
  bool isChargeExploitation() => role == ROLE_CHARGE_EXPLOITATION;
  
  bool isChargeConsignation() => role == ROLE_CHARGE_CONSIGNATION;
  
  // Helper method to check if user can create notes
  bool canCreateNotes() => isAdmin() || isChefExploitation() || isChargeConsignation();
  
  // Helper method to check if user can validate notes as Chef de Base
  bool canValidateAsChefDeBase() => isAdmin() || isChefDeBase();
  
  // Helper method to check if user can validate notes as Charge Exploitation
  bool canValidateAsChargeExploitation() => isAdmin() || isChargeExploitation();
  
  // Helper method to check if user can assign notes to Charge Consignation
  bool canAssignNotes() => isAdmin() || isChargeExploitation();
  
  // Helper method to check if user can perform consignation
  bool canPerformConsignation() => isAdmin() || isChargeConsignation();
  
  // Helper method to check if user can delete notes
  bool canDeleteNotes() => isAdmin();
}
