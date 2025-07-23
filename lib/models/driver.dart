// lib/models/driver.dart
class Driver {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String companyName;
  final String avatar;
  bool isPending;
  bool isDeleted;

  Driver({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.companyName,
    required this.avatar,
    this.isPending = true,
    this.isDeleted = false,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      isPending: json['isPending'] as bool? ?? true,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'companyName': companyName,
      'avatar': avatar,
      'isPending': isPending,
      'isDeleted': isDeleted,
    };
  }
}
