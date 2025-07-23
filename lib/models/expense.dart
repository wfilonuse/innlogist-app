class Expense {
  final int? id; // Додано ID для унікальної ідентифікації
  final int? fuel;
  final int? parking;
  final int? parts;
  final int? other;
  final String comment;
  final String time;
  bool isPending;

  Expense({
    this.id,
    this.fuel,
    this.parking,
    this.parts,
    this.other,
    required this.comment,
    required this.time,
    this.isPending = false,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as int?,
      fuel: json['fuel'] as int?,
      parking: json['parking'] as int?,
      parts: json['parts'] as int?,
      other: json['other'] as int?,
      comment: json['comment'] as String? ?? '',
      time: json['time'] as String? ?? '',
      isPending: json['isPending'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fuel': fuel,
      'parking': parking,
      'parts': parts,
      'other': other,
      'comment': comment,
      'time': time,
      'isPending': isPending,
    };
  }
}
