class Transport {
  final int id;
  final String number;
  final int statusId;
  final String model;
  final int tonnage;
  final String monitoring;
  final String company;
  final String type;
  final String rollingStockType;
  final String avatar;

  Transport({
    required this.id,
    required this.number,
    required this.statusId,
    required this.model,
    required this.tonnage,
    required this.monitoring,
    required this.company,
    required this.type,
    required this.rollingStockType,
    required this.avatar,
  });

  factory Transport.fromJson(Map<String, dynamic> json) {
    return Transport(
      id: json['id'] as int? ?? 0,
      number: json['number'] as String? ?? '',
      statusId: json['statusId'] as int? ?? 0,
      model: json['model'] as String? ?? '',
      tonnage: json['tonnage'] as int? ?? 0,
      monitoring: json['monitoring'] as String? ?? '',
      company: json['company'] as String? ?? '',
      type: json['type'] as String? ?? '',
      rollingStockType: json['rollingStockType'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'statusId': statusId,
      'model': model,
      'tonnage': tonnage,
      'monitoring': monitoring,
      'company': company,
      'type': type,
      'rollingStockType': rollingStockType,
      'avatar': avatar,
    };
  }
}
