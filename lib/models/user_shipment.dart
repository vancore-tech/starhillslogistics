class UserShipment {
  final String id;
  final String trackingNumber;
  final String? trackingUrl;
  final String senderName;
  final String senderAddress;
  final String senderCity;
  final String senderState;
  final String receiverName;
  final String receiverAddress;
  final String receiverCity;
  final String receiverState;
  final String status;
  final double amount;
  final String dateCreated;
  final List<ShipmentItem> items;

  UserShipment({
    required this.id,
    required this.trackingNumber,
    this.trackingUrl,
    required this.senderName,
    required this.senderAddress,
    required this.senderCity,
    required this.senderState,
    required this.receiverName,
    required this.receiverAddress,
    required this.receiverCity,
    required this.receiverState,
    required this.status,
    required this.amount,
    required this.dateCreated,
    required this.items,
  });

  factory UserShipment.fromJson(Map<String, dynamic> json) {
    return UserShipment(
      id: json['id'] ?? '',
      trackingNumber: json['trackingNumber'] ?? '',
      trackingUrl: json['trackingUrl'],
      senderName: json['senderName'] ?? '',
      senderAddress: json['senderAddress'] ?? '',
      senderCity: json['senderCity'] ?? '',
      senderState: json['senderState'] ?? '',
      receiverName: json['receiverName'] ?? '',
      receiverAddress: json['receiverAddress'] ?? '',
      receiverCity: json['receiverCity'] ?? '',
      receiverState: json['receiverState'] ?? '',
      status: json['status'] ?? 'pending',
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount'].toString()) ?? 0.0,
      dateCreated: json['dateCreated'] ?? '',
      items:
          (json['items'] as List?)
              ?.map((item) => ShipmentItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class ShipmentItem {
  final String name;
  final double price;
  final int quantity;

  ShipmentItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory ShipmentItem.fromJson(Map<String, dynamic> json) {
    return ShipmentItem(
      name: json['name'] ?? '',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price'].toString()) ?? 0.0,
      quantity: (json['quantity'] is num)
          ? (json['quantity'] as num).toInt()
          : int.tryParse(json['quantity'].toString()) ?? 1,
    );
  }
}
