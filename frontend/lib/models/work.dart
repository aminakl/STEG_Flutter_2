import 'user.dart';

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