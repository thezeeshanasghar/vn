class PaBrand {
  final int brandId;
  final String name;
  final double? amount;

  PaBrand({
    required this.brandId,
    required this.name,
    this.amount,
  });

  factory PaBrand.fromJson(Map<String, dynamic> json) {
    return PaBrand(
      brandId: (json['brandId'] as num).toInt(),
      name: json['name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble(),
    );
  }
}

