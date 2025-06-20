import 'package:intl/intl.dart';

class Notification {
  final String id;
  final String title;
  final String message;
  final String type;
  final String? relatedNoteId;
  final bool isRead;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.relatedNoteId,
    required this.isRead,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      relatedNoteId: json['relatedNoteId'],
      isRead: json['read'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'relatedNoteId': relatedNoteId,
      'read': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get formattedDate {
    return DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
  }

  String get typeIcon {
    switch (type) {
      case 'NOTE_CREATED':
        return 'assets/icons/note_created.png';
      case 'NOTE_VALIDATED_CHEF_BASE':
      case 'NOTE_VALIDATED_CHARGE_EXPLOITATION':
        return 'assets/icons/note_validated.png';
      case 'NOTE_REJECTED':
        return 'assets/icons/note_rejected.png';
      case 'NOTE_ASSIGNED':
        return 'assets/icons/note_assigned.png';
      case 'CONSIGNATION_STARTED':
      case 'CONSIGNATION_COMPLETED':
        return 'assets/icons/consignation.png';
      case 'DECONSIGNATION_STARTED':
      case 'DECONSIGNATION_COMPLETED':
        return 'assets/icons/deconsignation.png';
      case 'INCIDENT_REPORTED':
        return 'assets/icons/incident.png';
      default:
        return 'assets/icons/notification.png';
    }
  }

  String get typeColor {
    switch (type) {
      case 'NOTE_CREATED':
        return '#4CAF50'; // Green
      case 'NOTE_VALIDATED_CHEF_BASE':
      case 'NOTE_VALIDATED_CHARGE_EXPLOITATION':
        return '#2196F3'; // Blue
      case 'NOTE_REJECTED':
        return '#F44336'; // Red
      case 'NOTE_ASSIGNED':
        return '#FF9800'; // Orange
      case 'CONSIGNATION_STARTED':
      case 'CONSIGNATION_COMPLETED':
        return '#9C27B0'; // Purple
      case 'DECONSIGNATION_STARTED':
      case 'DECONSIGNATION_COMPLETED':
        return '#795548'; // Brown
      case 'INCIDENT_REPORTED':
        return '#D32F2F'; // Dark Red
      default:
        return '#607D8B'; // Blue Grey
    }
  }
}
