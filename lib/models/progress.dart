// lib/models/progress.dart
import 'address.dart';

class Progress {
  final int? id;
  final String name;
  final String date;
  final String type;
  final int position;
  final int completed;
  final Address? address;
  final String statusId;
  final String statusIdHistory;
  final String statusName;
  bool isPending;
  bool isDeleted;

  Progress({
    this.id,
    required this.name,
    required this.date,
    required this.type,
    required this.position,
    required this.completed,
    this.address,
    required this.statusId,
    required this.statusIdHistory,
    required this.statusName,
    this.isPending = true,
    this.isDeleted = false,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      date: json['date'] as String? ?? json['date_at'] as String? ?? '',
      type: json['type'] as String? ?? '',
      position: json['position'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
      address: json['address'] != null
          ? Address.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      statusId: json['status_id'] as String? ?? '',
      statusIdHistory: json['status_id_history'] as String? ?? '',
      statusName: json['status_name'] as String? ?? '',
      isPending: json['isPending'] as bool? ?? true,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date_at': date,
      'type': type,
      'position': position,
      'completed': completed,
      'address': address?.toJson(),
      'status_id': statusId,
      'status_id_history': statusIdHistory,
      'status_name': statusName,
      'isPending': isPending,
      'isDeleted': isDeleted,
    };
  }
}
