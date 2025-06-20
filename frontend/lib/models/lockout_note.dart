import 'package:frontend/models/user.dart';

enum NoteStatus {
  DRAFT,
  PENDING_CHEF_BASE,
  PENDING_CHARGE_EXPLOITATION,
  VALIDATED,
  REJECTED,
}

enum EquipmentType {
  TRANSFORMATEUR_MD,
  COUPLAGE_HT_MD,
  LIGNE_HT_MD,
}

extension EquipmentTypeExtension on EquipmentType {
  String get name => toString().split('.').last;
  String get displayName {
    switch (this) {
      case EquipmentType.TRANSFORMATEUR_MD:
        return 'TRANSFORMATEUR MD';
      case EquipmentType.COUPLAGE_HT_MD:
        return 'COUPLAGE HT/MD';
      case EquipmentType.LIGNE_HT_MD:
        return 'LIGNE HT/MD';
      default:
        return '';
    }
  }
  
  static EquipmentType? fromString(String? value) {
    if (value == null) return null;
    
    // Handle both display names and enum names
    switch (value) {
      // Display names (with spaces)
      case 'TRANSFORMATEUR MD':
        return EquipmentType.TRANSFORMATEUR_MD;
      case 'COUPLAGE HT/MD':
        return EquipmentType.COUPLAGE_HT_MD;
      case 'LIGNE HT/MD':
        return EquipmentType.LIGNE_HT_MD;
      
      // Enum names (with underscores)
      case 'TRANSFORMATEUR_MD':
        return EquipmentType.TRANSFORMATEUR_MD;
      case 'COUPLAGE_HT_MD':
        return EquipmentType.COUPLAGE_HT_MD;
      case 'LIGNE_HT_MD':
        return EquipmentType.LIGNE_HT_MD;
        
      default:
        return null;
    }
  }
}

extension NoteStatusExtension on NoteStatus {
  String get name {
    switch (this) {
      case NoteStatus.DRAFT:
        return 'Draft';
      case NoteStatus.PENDING_CHEF_BASE:
        return 'Pending Chef Base';
      case NoteStatus.PENDING_CHARGE_EXPLOITATION:
        return 'Pending Charge Exploitation';
      case NoteStatus.VALIDATED:
        return 'Validated';
      case NoteStatus.REJECTED:
        return 'Rejected';
      default:
        return '';
    }
  }
  
  bool get isPending {
    return this == NoteStatus.PENDING_CHEF_BASE || this == NoteStatus.PENDING_CHARGE_EXPLOITATION;
  }
}

class LockoutNote {
  final String id;
  final String posteHt;
  final NoteStatus status;
  final User? createdBy;
  final User? validatedByChefBase;
  final User? validatedByChargeExploitation;
  final User? assignedTo;
  final String? rejectionReason;
  final EquipmentType? equipmentType;
  final String? equipmentDetails;
  final String? uniteSteg;
  final String? workNature;
  final DateTime? retraitDate;
  final DateTime? debutTravaux;
  final DateTime? finTravaux;
  final DateTime? retourDate;
  final int? joursIndisponibilite;
  final String? chargeRetrait;
  final String? chargeConsignation;
  final String? chargeTravaux;
  final String? chargeEssais;
  final String? instructionsTechniques;
  final String? destinataires;
  final String? coupureDemandeePar;
  final String? noteTransmiseA;
  final DateTime createdAt;
  final DateTime? validatedAtChefBase;
  final DateTime? validatedAtChargeExploitation;
  final DateTime? assignedAt;
  final DateTime? consignationStartedAt;
  final DateTime? consignationCompletedAt;
  final DateTime? deconsignationStartedAt;
  final DateTime? deconsignationCompletedAt;
  final Work? work;

  LockoutNote({
    required this.id,
    required this.posteHt,
    required this.status,
    this.createdBy,
    this.validatedByChefBase,
    this.validatedByChargeExploitation,
    this.assignedTo,
    this.rejectionReason,
    this.equipmentType,
    this.equipmentDetails,
    this.uniteSteg,
    this.workNature,
    this.retraitDate,
    this.debutTravaux,
    this.finTravaux,
    this.retourDate,
    this.joursIndisponibilite,
    this.chargeRetrait,
    this.chargeConsignation,
    this.chargeTravaux,
    this.chargeEssais,
    this.instructionsTechniques,
    this.destinataires,
    this.coupureDemandeePar,
    this.noteTransmiseA,
    required this.createdAt,
    this.validatedAtChefBase,
    this.validatedAtChargeExploitation,
    this.assignedAt,
    this.consignationStartedAt,
    this.consignationCompletedAt,
    this.deconsignationStartedAt,
    this.deconsignationCompletedAt,
    this.work,
  });

  factory LockoutNote.fromJson(Map<String, dynamic> json) {
    print('Parsing note: $json'); // Debug print
    try {
      return LockoutNote(
        id: json['id']?.toString() ?? '', // Convert UUID to string
        posteHt: json['posteHt'] ?? '',
        status: NoteStatus.values.firstWhere(
          (e) => e.toString() == 'NoteStatus.${json['status']}',
          orElse: () => NoteStatus.DRAFT,
        ),
        createdBy: json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
        validatedByChefBase: json['validatedByChefBase'] != null ? User.fromJson(json['validatedByChefBase']) : null,
        validatedByChargeExploitation: json['validatedByChargeExploitation'] != null ? User.fromJson(json['validatedByChargeExploitation']) : null,
        assignedTo: json['assignedTo'] != null ? User.fromJson(json['assignedTo']) : null,
        rejectionReason: json['rejectionReason'],
        equipmentType: json['equipmentType'] != null ? 
          EquipmentTypeExtension.fromString(json['equipmentType']) : null,
        equipmentDetails: json['equipmentDetails'],
        uniteSteg: json['uniteSteg'],
        workNature: json['workNature'],
        retraitDate: json['retraitDate'] != null ? 
          DateTime.tryParse(json['retraitDate']) : null,
        debutTravaux: json['debutTravaux'] != null ? 
          DateTime.tryParse(json['debutTravaux']) : null,
        finTravaux: json['finTravaux'] != null ? 
          DateTime.tryParse(json['finTravaux']) : null,
        retourDate: json['retourDate'] != null ? 
          DateTime.tryParse(json['retourDate']) : null,
        joursIndisponibilite: json['joursIndisponibilite'],
        chargeRetrait: json['chargeRetrait'],
        chargeConsignation: json['chargeConsignation'],
        chargeTravaux: json['chargeTravaux'],
        chargeEssais: json['chargeEssais'],
        instructionsTechniques: json['instructionsTechniques'],
        destinataires: json['destinataires'],
        coupureDemandeePar: json['coupureDemandeePar'],
        noteTransmiseA: json['noteTransmiseA'],
        createdAt: json['createdAt'] != null ? 
          DateTime.tryParse(json['createdAt']) ?? DateTime.now() : DateTime.now(),
        validatedAtChefBase: json['validatedAtChefBase'] != null ? 
          DateTime.tryParse(json['validatedAtChefBase']) : null,
        validatedAtChargeExploitation: json['validatedAtChargeExploitation'] != null ? 
          DateTime.tryParse(json['validatedAtChargeExploitation']) : null,
        assignedAt: json['assignedAt'] != null ? 
          DateTime.tryParse(json['assignedAt']) : null,
        consignationStartedAt: json['consignationStartedAt'] != null ? 
          DateTime.tryParse(json['consignationStartedAt']) : null,
        consignationCompletedAt: json['consignationCompletedAt'] != null ? 
          DateTime.tryParse(json['consignationCompletedAt']) : null,
        deconsignationStartedAt: json['deconsignationStartedAt'] != null ? 
          DateTime.tryParse(json['deconsignationStartedAt']) : null,
        deconsignationCompletedAt: json['deconsignationCompletedAt'] != null ? 
          DateTime.tryParse(json['deconsignationCompletedAt']) : null,
        work: json['work'] != null ? Work.fromJson(json['work']) : null,
      );
    } catch (e) {
      print('Error parsing note: $e');
      // Return a default note in case of parsing error
      return LockoutNote(
        id: json['id']?.toString() ?? 'error',
        posteHt: json['posteHt'] ?? 'Error parsing note',
        status: NoteStatus.DRAFT,
        createdAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'posteHt': posteHt,
      'status': status.toString().split('.').last,
      'createdBy': createdBy?.toJson(),
      'validatedByChefBase': validatedByChefBase?.toJson(),
      'validatedByChargeExploitation': validatedByChargeExploitation?.toJson(),
      'assignedTo': assignedTo?.toJson(),
      'rejectionReason': rejectionReason,
      'equipmentType': equipmentType?.displayName,
      'equipmentDetails': equipmentDetails,
      'uniteSteg': uniteSteg,
      'workNature': workNature,
      'retraitDate': retraitDate?.toIso8601String(),
      'debutTravaux': debutTravaux?.toIso8601String(),
      'finTravaux': finTravaux?.toIso8601String(),
      'retourDate': retourDate?.toIso8601String(),
      'joursIndisponibilite': joursIndisponibilite,
      'chargeRetrait': chargeRetrait,
      'chargeConsignation': chargeConsignation,
      'chargeTravaux': chargeTravaux,
      'chargeEssais': chargeEssais,
      'instructionsTechniques': instructionsTechniques,
      'destinataires': destinataires,
      'coupureDemandeePar': coupureDemandeePar,
      'noteTransmiseA': noteTransmiseA,
      'createdAt': createdAt.toIso8601String(),
      'validatedAtChefBase': validatedAtChefBase?.toIso8601String(),
      'validatedAtChargeExploitation': validatedAtChargeExploitation?.toIso8601String(),
      'assignedAt': assignedAt?.toIso8601String(),
      'consignationStartedAt': consignationStartedAt?.toIso8601String(),
      'consignationCompletedAt': consignationCompletedAt?.toIso8601String(),
      'deconsignationStartedAt': deconsignationStartedAt?.toIso8601String(),
      'deconsignationCompletedAt': deconsignationCompletedAt?.toIso8601String(),
      'work': work?.toJson(),
    };
  }
}

class Work {
  final String id;
  final String description;
  final User worker;
  final DateTime createdAt;
  final DateTime updatedAt;

  Work({
    required this.id,
    required this.description,
    required this.worker,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Work.fromJson(Map<String, dynamic> json) {
    return Work(
      id: json['id']?.toString() ?? '',
      description: json['description'] ?? '',
      worker: User.fromJson(json['worker']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'worker': worker.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
