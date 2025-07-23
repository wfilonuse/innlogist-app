// lib/models/fuel_consumption.dart
class FuelConsumption {
  final int? id;
  final double amount;
  final String date;
  bool isPending;
  bool isDeleted;

  FuelConsumption({
    this.id,
    required this.amount,
    required this.date,
    this.isPending = true,
    this.isDeleted = false,
  });

  factory FuelConsumption.fromJson(Map<String, dynamic> json) {
    return FuelConsumption(
      id: json['id'] as int?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] as String? ?? '',
      isPending: json['isPending'] as bool? ?? true,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date,
      'isPending': isPending,
      'isDeleted': isDeleted,
    };
  }
}
