enum EquipmentType {
  TRANSFORMATEUR,
  COUPLAGE,
  LIGNE_HT;

  String get displayName {
    switch (this) {
      case EquipmentType.TRANSFORMATEUR:
        return 'TRANSFORMATEUR';
      case EquipmentType.COUPLAGE:
        return 'COUPLAGE';
      case EquipmentType.LIGNE_HT:
        return 'LIGNE HT';
    }
  }

  static EquipmentType? fromString(String? value) {
    if (value == null) return null;
    
    switch (value.toUpperCase()) {
      case 'TRANSFORMATEUR':
        return EquipmentType.TRANSFORMATEUR;
      case 'COUPLAGE':
        return EquipmentType.COUPLAGE;
      case 'LIGNE_HT':
        return EquipmentType.LIGNE_HT;
      default:
        return null;
    }
  }
} 