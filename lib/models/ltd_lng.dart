// lib/models/ltd_lng.dart
class LtdLng {
  final int? id;
  final double lat;
  final double lng;
  final int time;
  final double odometer;
  final double deviation;
  final int statusId;
  bool isPending;
  bool isDeleted;

  LtdLng({
    this.id,
    required this.lat,
    required this.lng,
    required this.time,
    required this.odometer,
    required this.deviation,
    required this.statusId,
    this.isPending = true,
    this.isDeleted = false,
  });

  factory LtdLng.fromJson(Map<String, dynamic> json) {
    return LtdLng(
      id: json['id'] as int?,
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      time: json['time'] as int? ?? 0,
      odometer: (json['odometer'] as num?)?.toDouble() ?? 0.0,
      deviation: (json['deviation'] as num?)?.toDouble() ?? 0.0,
      statusId: json['statusId'] as int? ?? 0,
      isPending: json['isPending'] as bool? ?? true,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lat': lat,
      'lng': lng,
      'time': time,
      'odometer': odometer,
      'deviation': deviation,
      'statusId': statusId,
      'isPending': isPending,
      'isDeleted': isDeleted,
    };
  }
}
