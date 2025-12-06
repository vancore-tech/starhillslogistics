class RateCourierModel {
  String? courierId;
  String? courierName;
  String? courierImage;
  String? serviceCode;
  Insurance? insurance;
  Discount? discount;
  String? serviceType;
  bool? waybill;
  bool? onDemand;
  bool? isCodAvailable;
  int? trackingLevel;
  double? ratings;
  int? votes;
  bool? connectedAccount;
  double? rateCardAmount;
  String? rateCardCurrency;
  String? pickupEta;
  String? pickupEtaTime;
  String? dropoffStation;
  String? pickupStation;
  String? deliveryEta;
  String? deliveryEtaTime;
  List<String>? info;
  String? currency;
  double? vat;
  double? total;
  Tracking? tracking;

  RateCourierModel({
    this.courierId,
    this.courierName,
    this.courierImage,
    this.serviceCode,
    this.insurance,
    this.discount,
    this.serviceType,
    this.waybill,
    this.onDemand,
    this.isCodAvailable,
    this.trackingLevel,
    this.ratings,
    this.votes,
    this.connectedAccount,
    this.rateCardAmount,
    this.rateCardCurrency,
    this.pickupEta,
    this.pickupEtaTime,
    this.dropoffStation,
    this.pickupStation,
    this.deliveryEta,
    this.deliveryEtaTime,
    this.info,
    this.currency,
    this.vat,
    this.total,
    this.tracking,
  });

  factory RateCourierModel.fromJson(Map<String, dynamic> json) {
    return RateCourierModel(
      courierId: json['courier_id'],
      courierName: json['courier_name'],
      courierImage: json['courier_image'],
      serviceCode: json['service_code'],
      insurance: json['insurance'] != null
          ? Insurance.fromJson(json['insurance'])
          : null,
      discount: json['discount'] != null
          ? Discount.fromJson(json['discount'])
          : null,
      serviceType: json['service_type'],
      waybill: json['waybill'],
      onDemand: json['on_demand'],
      isCodAvailable: json['is_cod_available'],
      trackingLevel: json['tracking_level'],
      ratings: json['ratings']?.toDouble(),
      votes: json['votes'],
      connectedAccount: json['connected_account'],
      rateCardAmount: json['rate_card_amount']?.toDouble(),
      rateCardCurrency: json['rate_card_currency'],
      pickupEta: json['pickup_eta'],
      pickupEtaTime: json['pickup_eta_time'],
      dropoffStation: json['dropoff_station'],
      pickupStation: json['pickup_station'],
      deliveryEta: json['delivery_eta'],
      deliveryEtaTime: json['delivery_eta_time'],
      info: json['info'] != null ? List<String>.from(json['info']) : null,
      currency: json['currency'],
      vat: json['vat']?.toDouble(),
      total: json['total']?.toDouble(),
      tracking: json['tracking'] != null
          ? Tracking.fromJson(json['tracking'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courier_id': courierId,
      'courier_name': courierName,
      'courier_image': courierImage,
      'service_code': serviceCode,
      'insurance': insurance?.toJson(),
      'discount': discount?.toJson(),
      'service_type': serviceType,
      'waybill': waybill,
      'on_demand': onDemand,
      'is_cod_available': isCodAvailable,
      'tracking_level': trackingLevel,
      'ratings': ratings,
      'votes': votes,
      'connected_account': connectedAccount,
      'rate_card_amount': rateCardAmount,
      'rate_card_currency': rateCardCurrency,
      'pickup_eta': pickupEta,
      'pickup_eta_time': pickupEtaTime,
      'dropoff_station': dropoffStation,
      'pickup_station': pickupStation,
      'delivery_eta': deliveryEta,
      'delivery_eta_time': deliveryEtaTime,
      'info': info,
      'currency': currency,
      'vat': vat,
      'total': total,
      'tracking': tracking?.toJson(),
    };
  }
}

class Insurance {
  String? code;
  double? fee;

  Insurance({this.code, this.fee});

  factory Insurance.fromJson(Map<String, dynamic> json) {
    return Insurance(code: json['code'], fee: json['fee']?.toDouble());
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'fee': fee};
  }
}

class Discount {
  int? percentage;
  String? symbol;
  double? discounted;

  Discount({this.percentage, this.symbol, this.discounted});

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      percentage: json['percentage'],
      symbol: json['symbol'],
      discounted: json['discounted']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'percentage': percentage,
      'symbol': symbol,
      'discounted': discounted,
    };
  }
}

class Tracking {
  int? bars;
  String? label;

  Tracking({this.bars, this.label});

  factory Tracking.fromJson(Map<String, dynamic> json) {
    return Tracking(bars: json['bars'], label: json['label']);
  }

  Map<String, dynamic> toJson() {
    return {'bars': bars, 'label': label};
  }
}
