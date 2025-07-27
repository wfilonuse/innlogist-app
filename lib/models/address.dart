class Address {
  final int? id; // Додано ID для унікальної ідентифікації
  final String address;
  final String type;
  final double lat;
  final double lng;
  final String dateAt;

  Address({
    this.id,
    required this.address,
    required this.type,
    required this.lat,
    required this.lng,
    required this.dateAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as int?,
      address: json['address'] as String? ?? '',
      type: json['type'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      dateAt: json['dateAt'] as String? ?? json['date_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'type': type,
      'lat': lat,
      'lng': lng,
      'dateAt': dateAt,
    };
  }
}
