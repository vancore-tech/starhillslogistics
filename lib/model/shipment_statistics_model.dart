class ShipmentStatisticsModel {
  final int total;
  final int delivered;
  final int inTransit;
  final int cancelled;
  final num revenue;
  final num deliveryRate;

  ShipmentStatisticsModel({
    required this.total,
    required this.delivered,
    required this.inTransit,
    required this.cancelled,
    required this.revenue,
    required this.deliveryRate,
  });

  factory ShipmentStatisticsModel.fromJson(Map<String, dynamic> json) {
    return ShipmentStatisticsModel(
      total: _parseInt(json['total']),
      delivered: _parseInt(json['delivered']),
      inTransit: _parseInt(
        json['in_transit'] ?? json['transit'] ?? json['inTransit'],
      ),
      cancelled: _parseInt(json['cancelled']),
      revenue: _parseNum(json['revenue']),
      deliveryRate: _parseNum(json['delivery_rate'] ?? json['deliveryRate']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static num _parseNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }
}
