// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  String? id;
  String? email;
  String? phone;
  String? password;
  String? fullName;
  String? role;
  bool? isPhoneVerified;
  bool? isEmailVerified;
  dynamic otp;
  dynamic otpExpiry;
  String? refreshToken;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic profile;
  Wallet? wallet;
  dynamic bankAccount;

  UserModel({
    this.id,
    this.email,
    this.phone,
    this.password,
    this.fullName,
    this.role,
    this.isPhoneVerified,
    this.isEmailVerified,
    this.otp,
    this.otpExpiry,
    this.refreshToken,
    this.createdAt,
    this.updatedAt,
    this.profile,
    this.wallet,
    this.bankAccount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    email: json["email"],
    phone: json["phone"],
    password: json["password"],
    fullName: json["fullName"],
    role: json["role"],
    isPhoneVerified: json["isPhoneVerified"],
    isEmailVerified: json["isEmailVerified"],
    otp: json["otp"],
    otpExpiry: json["otpExpiry"],
    refreshToken: json["refreshToken"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    profile: json["profile"],
    wallet: json["wallet"] == null ? null : Wallet.fromJson(json["wallet"]),
    bankAccount: json["bankAccount"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "phone": phone,
    "password": password,
    "fullName": fullName,
    "role": role,
    "isPhoneVerified": isPhoneVerified,
    "isEmailVerified": isEmailVerified,
    "otp": otp,
    "otpExpiry": otpExpiry,
    "refreshToken": refreshToken,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "profile": profile,
    "wallet": wallet?.toJson(),
    "bankAccount": bankAccount,
  };
}

class Wallet {
  String? id;
  String? userId;
  int? balance;

  Wallet({this.id, this.userId, this.balance});

  factory Wallet.fromJson(Map<String, dynamic> json) =>
      Wallet(id: json["id"], userId: json["userId"], balance: json["balance"]);

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "balance": balance,
  };
}
