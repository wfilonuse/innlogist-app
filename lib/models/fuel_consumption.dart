class FuelConsumption {
  final String id;
  final int mileage;
  final double liters;
  final String date;

  FuelConsumption({
    required this.id,
    required this.mileage,
    required this.liters,
    required this.date,
  });

  factory FuelConsumption.fromJson(Map<String, dynamic> json) {
    return FuelConsumption(
      id: json['id'] as String,
      mileage: json['mileage'] as int,
      liters: (json['liters'] as num).toDouble(),
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mileage': mileage,
      'liters': liters,
      'date': date,
    };
  }
}
