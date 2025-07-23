class Report {
  final int? id;
  final int? fuel;
  final int? parking;
  final int? parts;
  final int? other;
  final double? distance;
  final double? distanceEmpty;
  final String? duration;
  final int? amount;
  final int? amountFact;
  final int? orders;
  final String? dateFrom;
  final String? dateTo;
  final int? fuelBalanceStartCurrentMonth;
  final int? lastTripDays;
  final int? expenses;
  bool isPending;

  Report({
    this.id,
    this.fuel,
    this.parking,
    this.parts,
    this.other,
    this.distance,
    this.distanceEmpty,
    this.duration,
    this.amount,
    this.amountFact,
    this.orders,
    this.dateFrom,
    this.dateTo,
    this.fuelBalanceStartCurrentMonth,
    this.lastTripDays,
    this.expenses,
    this.isPending = false,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as int?,
      fuel: json['fuel'] as int?,
      parking: json['parking'] as int?,
      parts: json['parts'] as int?,
      other: json['other'] as int?,
      distance: (json['distance'] as num?)?.toDouble(),
      distanceEmpty: (json['distanceEmpty'] as num?)?.toDouble(),
      duration: json['duration'] as String?,
      amount: json['amount'] as int?,
      amountFact: json['amountFact'] as int?,
      orders: json['orders'] as int?,
      dateFrom: json['dateFrom'] as String?,
      dateTo: json['dateTo'] as String?,
      fuelBalanceStartCurrentMonth:
          json['fuelBalanceStartCurrentMonth'] as int?,
      lastTripDays: json['lastTripDays'] as int?,
      expenses: json['expenses'] as int?,
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
      'distance': distance,
      'distanceEmpty': distanceEmpty,
      'duration': duration,
      'amount': amount,
      'amountFact': amountFact,
      'orders': orders,
      'dateFrom': dateFrom,
      'dateTo': dateTo,
      'fuelBalanceStartCurrentMonth': fuelBalanceStartCurrentMonth,
      'lastTripDays': lastTripDays,
      'expenses': expenses,
      'isPending': isPending,
    };
  }
}
