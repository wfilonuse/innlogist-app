import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Way {
  final int orderId;
  final List<LatLng> list;

  Way({
    required this.orderId,
    required this.list,
  });

  factory Way.fromJson(Map<String, dynamic> json) {
    return Way(
      orderId: json['orderId'] as int? ?? 0,
      list: json['list'] != null
          ? (jsonDecode(json['list'] as String) as List)
              .map((e) => LatLng(e['lat'] as double, e['lng'] as double))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'list': jsonEncode(
          list.map((e) => {'lat': e.latitude, 'lng': e.longitude}).toList()),
    };
  }
}
