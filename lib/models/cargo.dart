class Cargo {
  final int? id; // Додано ID для унікальної ідентифікації
  final String name;
  final String description;
  final double weight;
  final double volume;
  final String type;

  Cargo({
    this.id,
    required this.name,
    required this.description,
    required this.weight,
    required this.volume,
    required this.type,
  });

  factory Cargo.fromJson(Map<String, dynamic> json) {
    return Cargo(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'weight': weight,
      'volume': volume,
      'type': type,
    };
  }
}
