import '../models/equipment_type.dart';

class ChecklistItem {
  final String description;
  final String? designation;
  final bool requiresTimer;

  const ChecklistItem({
    required this.description,
    this.designation,
    this.requiresTimer = false,
  });
}

class EquipmentChecklists {
  static const Map<EquipmentType, List<ChecklistItem>> consignationChecklists = {
    EquipmentType.TRANSFORMATEUR: [
      ChecklistItem(
        description: 'Vérifier l\'absence de tension sur le transformateur',
        designation: 'Transformateur',
      ),
      ChecklistItem(
        description: 'Mettre en position "OFF" le disjoncteur HT',
        designation: 'Disjoncteur HT',
      ),
      ChecklistItem(
        description: 'Mettre en position "OFF" le disjoncteur BT',
        designation: 'Disjoncteur BT',
      ),
      ChecklistItem(
        description: 'Vérifier l\'absence de tension sur les bornes HT',
        designation: 'Bornes HT',
        requiresTimer: true,
      ),
      ChecklistItem(
        description: 'Vérifier l\'absence de tension sur les bornes BT',
        designation: 'Bornes BT',
        requiresTimer: true,
      ),
      ChecklistItem(
        description: 'Mettre en position "EARTH" le sectionneur de terre HT',
        designation: 'Sectionneur de terre HT',
      ),
      ChecklistItem(
        description: 'Mettre en position "EARTH" le sectionneur de terre BT',
        designation: 'Sectionneur de terre BT',
      ),
      ChecklistItem(
        description: 'Placer les cadenas de sécurité sur les sectionneurs',
        designation: 'Cadenas de sécurité',
      ),
    ],
    EquipmentType.LIGNE_HT: [
      ChecklistItem(
        description: 'Vérifier l\'absence de tension sur la ligne',
        designation: 'Ligne HT',
      ),
      ChecklistItem(
        description: 'Mettre en position "OFF" le disjoncteur de ligne',
        designation: 'Disjoncteur de ligne',
      ),
      ChecklistItem(
        description: 'Vérifier l\'absence de tension sur les bornes',
        designation: 'Bornes',
        requiresTimer: true,
      ),
      ChecklistItem(
        description: 'Mettre en position "EARTH" le sectionneur de terre',
        designation: 'Sectionneur de terre',
      ),
      ChecklistItem(
        description: 'Placer les cadenas de sécurité sur les sectionneurs',
        designation: 'Cadenas de sécurité',
      ),
    ],
    EquipmentType.COUPLAGE: [
      ChecklistItem(
        description: 'Vérifier l\'absence de tension sur le couplage',
        designation: 'Couplage',
      ),
      ChecklistItem(
        description: 'Mettre en position "OFF" le disjoncteur de couplage',
        designation: 'Disjoncteur de couplage',
      ),
      ChecklistItem(
        description: 'Vérifier l\'absence de tension sur les bornes',
        designation: 'Bornes',
        requiresTimer: true,
      ),
      ChecklistItem(
        description: 'Mettre en position "EARTH" le sectionneur de terre',
        designation: 'Sectionneur de terre',
      ),
      ChecklistItem(
        description: 'Placer les cadenas de sécurité sur les sectionneurs',
        designation: 'Cadenas de sécurité',
      ),
    ],
  };

  static const Map<EquipmentType, List<ChecklistItem>> deconsignationChecklists = {
    EquipmentType.TRANSFORMATEUR: [
      ChecklistItem(
        description: 'Vérifier l\'absence de personnel dans la zone',
        designation: 'Zone de travail',
      ),
      ChecklistItem(
        description: 'Retirer les cadenas de sécurité des sectionneurs',
        designation: 'Cadenas de sécurité',
      ),
      ChecklistItem(
        description: 'Mettre en position "OFF" le sectionneur de terre HT',
        designation: 'Sectionneur de terre HT',
      ),
      ChecklistItem(
        description: 'Mettre en position "OFF" le sectionneur de terre BT',
        designation: 'Sectionneur de terre BT',
      ),
      ChecklistItem(
        description: 'Vérifier l\'absence de tension sur les bornes HT',
        designation: 'Bornes HT',
        requiresTimer: true,
      ),
      ChecklistItem(
        description: 'Vérifier l\'absence de tension sur les bornes BT',
        designation: 'Bornes BT',
        requiresTimer: true,
      ),
      ChecklistItem(
        description: 'Mettre en position "ON" le disjoncteur HT',
        designation: 'Disjoncteur HT',
      ),
      ChecklistItem(
        description: 'Mettre en position "ON" le disjoncteur BT',
        designation: 'Disjoncteur BT',
      ),
    ],
    EquipmentType.LIGNE_HT: [
      ChecklistItem(
        description: 'Vérifier l\'absence de personnel dans la zone',
        designation: 'Zone de travail',
      ),
      ChecklistItem(
        description: 'Retirer les cadenas de sécurité des sectionneurs',
        designation: 'Cadenas de sécurité',
      ),
      ChecklistItem(
        description: 'Mettre en position "OFF" le sectionneur de terre',
        designation: 'Sectionneur de terre',
      ),
      ChecklistItem(
        description: 'Vérifier l\'absence de tension sur les bornes',
        designation: 'Bornes',
        requiresTimer: true,
      ),
      ChecklistItem(
        description: 'Mettre en position "ON" le disjoncteur de ligne',
        designation: 'Disjoncteur de ligne',
      ),
    ],
    EquipmentType.COUPLAGE: [
      ChecklistItem(
        description: 'Vérifier l\'absence de personnel dans la zone',
        designation: 'Zone de travail',
      ),
      ChecklistItem(
        description: 'Retirer les cadenas de sécurité des sectionneurs',
        designation: 'Cadenas de sécurité',
      ),
      ChecklistItem(
        description: 'Mettre en position "OFF" le sectionneur de terre',
        designation: 'Sectionneur de terre',
      ),
      ChecklistItem(
        description: 'Vérifier l\'absence de tension sur les bornes',
        designation: 'Bornes',
        requiresTimer: true,
      ),
      ChecklistItem(
        description: 'Mettre en position "ON" le disjoncteur de couplage',
        designation: 'Disjoncteur de couplage',
      ),
    ],
  };
} 