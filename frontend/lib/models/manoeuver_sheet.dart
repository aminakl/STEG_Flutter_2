import 'equipment_type.dart';
import 'work_attestation.dart';

class ManoeuverSheet {
  final String id;
  final String lockoutNoteId;
  final String userId;
  final EquipmentType equipmentType;
  final bool epiVerified;
  final bool consignationStarted;
  final bool consignationCompleted;
  final bool deconsignationStarted;
  final bool deconsignationCompleted;
  final String? workAttestationId;
  final WorkAttestation? workAttestation;
  final DateTime createdAt;
  final DateTime updatedAt;

  ManoeuverSheet({
    required this.id,
    required this.lockoutNoteId,
    required this.userId,
    required this.equipmentType,
    this.epiVerified = false,
    this.consignationStarted = false,
    this.consignationCompleted = false,
    this.deconsignationStarted = false,
    this.deconsignationCompleted = false,
    this.workAttestationId,
    this.workAttestation,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ManoeuverSheet.fromJson(Map<String, dynamic> json) {
    return ManoeuverSheet(
      id: json['id']?.toString() ?? '',
      lockoutNoteId: json['lockoutNote'] != null ? json['lockoutNote']['id']?.toString() ?? '' : '',
      userId: json['createdBy'] != null ? json['createdBy']['id']?.toString() ?? '' : '',
      equipmentType: EquipmentType.fromString(json['equipmentType']) ?? EquipmentType.TRANSFORMATEUR,
      epiVerified: json['epiVerified'] ?? false,
      consignationStarted: json['consignationStarted'] ?? false,
      consignationCompleted: json['consignationCompleted'] ?? false,
      deconsignationStarted: json['deconsignationStarted'] ?? false,
      deconsignationCompleted: json['deconsignationCompleted'] ?? false,
      workAttestationId: json['workAttestationId']?.toString(),
      workAttestation: json['workAttestation'] != null ? WorkAttestation.fromJson(json['workAttestation']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lockoutNoteId': lockoutNoteId,
      'userId': userId,
      'equipmentType': equipmentType.name,
      'epiVerified': epiVerified,
      'consignationStarted': consignationStarted,
      'consignationCompleted': consignationCompleted,
      'deconsignationStarted': deconsignationStarted,
      'deconsignationCompleted': deconsignationCompleted,
      'workAttestationId': workAttestationId,
      'workAttestation': workAttestation?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String getEquipmentSchemaPath() {
    switch (equipmentType) {
      case EquipmentType.TRANSFORMATEUR:
        return 'assets/schemas/TRANSFORMATEUR.png';
      case EquipmentType.LIGNE_HT:
        return 'assets/schemas/LIGNE_HT.png';
      case EquipmentType.COUPLAGE:
        return 'assets/schemas/COUPLAGE.png';
    }
  }
} 