class Status {
  final int id;
  final String address;
  final double lat;
  final double lng;
  final String date;

  Status({
    required this.id,
    required this.address,
    required this.lat,
    required this.lng,
    required this.date,
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      id: json['id'] as int? ?? 0,
      address: json['address'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'lat': lat,
      'lng': lng,
      'date': date,
    };
  }
}
