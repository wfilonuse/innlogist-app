class Driver {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String companyName;

  Driver({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.companyName,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'companyName': companyName,
    };
  }
}
