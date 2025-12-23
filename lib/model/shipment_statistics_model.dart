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
      total: json['total'] ?? 0,
      delivered: json['delivered'] ?? 0,
      inTransit: json['inTransit'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
      revenue: json['revenue'] ?? 0,
      deliveryRate: json['deliveryRate'] ?? 0,
    );
  }
}
