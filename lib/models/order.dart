// lib/models/order.dart
import 'address.dart';
import 'cargo.dart';
import 'document.dart';
import 'location.dart';
import 'progress.dart';

class Order {
  final int id;
  final String status;
  final String clientName;
  final String clientPhone;
  final List<Progress> progress;
  final Cargo cargo;
  final double currentPrice;
  final String currency;
  final String paymentType;
  final String arrivalTime;
  final List<Address> addresses;
  final String downloadDate;
  final String uploadDate;
  final List<Document> documents;
  final List<Location> locations;
  bool isPending;
  bool isDeleted;

  Order({
    required this.id,
    required this.status,
    required this.clientName,
    required this.clientPhone,
    required this.progress,
    required this.cargo,
    required this.currentPrice,
    required this.currency,
    required this.paymentType,
    required this.arrivalTime,
    required this.addresses,
    required this.downloadDate,
    required this.uploadDate,
    required this.documents,
    required this.locations,
    this.isPending = true,
    this.isDeleted = false,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      clientName: json['clientName'] as String? ?? '',
      clientPhone: json['clientPhone'] as String? ?? '',
      progress: (json['progress'] as List?)
              ?.map((e) => Progress.fromJson(e))
              .toList() ??
          [],
      cargo: Cargo.fromJson(json['cargo'] as Map<String, dynamic>? ?? {}),
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? '',
      paymentType: json['paymentType'] as String? ?? '',
      arrivalTime: json['arrivalTime'] as String? ?? '',
      addresses: (json['addresses'] as List?)
              ?.map((e) => Address.fromJson(e))
              .toList() ??
          [],
      downloadDate: json['downloadDate'] as String? ?? '',
      uploadDate: json['uploadDate'] as String? ?? '',
      documents: (json['documents'] as List?)
              ?.map((e) => Document.fromJson(e))
              .toList() ??
          [],
      locations: (json['locations'] as List?)
              ?.map((e) => Location.fromJson(e))
              .toList() ??
          [],
      isPending: json['isPending'] as bool? ?? true,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'progress': progress.map((e) => e.toJson()).toList(),
      'cargo': cargo.toJson(),
      'currentPrice': currentPrice,
      'currency': currency,
      'paymentType': paymentType,
      'arrivalTime': arrivalTime,
      'addresses': addresses.map((e) => e.toJson()).toList(),
      'downloadDate': downloadDate,
      'uploadDate': uploadDate,
      'documents': documents.map((e) => e.toJson()).toList(),
      'locations': locations.map((e) => e.toJson()).toList(),
      'isPending': isPending,
      'isDeleted': isDeleted,
    };
  }
}
