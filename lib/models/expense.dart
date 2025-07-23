// lib/models/expense.dart
class Expense {
  final int? id;
  final int? fuel;
  final int? parking;
  final int? parts;
  final int? other;
  final String? comment;
  final String time;
  bool isPending;
  bool isDeleted;

  Expense({
    this.id,
    this.fuel,
    this.parking,
    this.parts,
    this.other,
    this.comment,
    required this.time,
    this.isPending = true,
    this.isDeleted = false,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as int?,
      fuel: json['fuel'] as int?,
      parking: json['parking'] as int?,
      parts: json['parts'] as int?,
      other: json['other'] as int?,
      comment: json['comment'] as String?,
      time: json['time'] as String? ?? '',
      isPending: json['isPending'] as bool? ?? true,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fuel': fuel,
      'parking': parking,
      'parts': parts,
      'other': other,
      'comment': comment,
      'time': time,
      'isPending': isPending,
      'isDeleted': isDeleted,
    };
  }
}
