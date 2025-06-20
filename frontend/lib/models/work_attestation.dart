import 'user.dart';
import 'work.dart';
import 'equipment_type.dart';

class WorkAttestation {
  final String id;
  final String manoeuverSheetId;
  final Work work;
  final User worker;
  final List<EquipmentType> equipmentTypes;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkAttestation({
    required this.id,
    required this.manoeuverSheetId,
    required this.work,
    required this.worker,
    required this.equipmentTypes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkAttestation.fromJson(Map<String, dynamic> json) {
    return WorkAttestation(
      id: json['id'],
      manoeuverSheetId: json['manoeuverSheet']['id'],
      work: Work.fromJson(json['work']),
      worker: User.fromJson(json['worker']),
      equipmentTypes: (json['equipmentTypes'] as List)
          .map((type) => EquipmentType.fromString(type.toString()) ?? EquipmentType.TRANSFORMATEUR)
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'manoeuverSheetId': manoeuverSheetId,
      'work': work.toJson(),
      'worker': worker.toJson(),
      'equipmentTypes': equipmentTypes.map((type) => type.name).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
} 