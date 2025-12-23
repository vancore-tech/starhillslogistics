import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:starhills/const/api_config.dart';
import 'package:starhills/utils/storage_helper.dart' as StorageHelper;

class ShipmentController extends GetxController {
  var isLoadingRates = false.obs;
  var isCreatingShipment = false.obs;
  var couriers = <Map<String, dynamic>>[].obs;
  var selectedCourierIndex = RxnInt();

  Future<void> fetchRates(Map<String, dynamic> rateRequestBody) async {
    isLoadingRates.value = true;
    try {
      final token = await StorageHelper.getToken();
      final response = await http.post(
        Uri.parse(ApiConfig.baseUrl + 'rates/calculate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(rateRequestBody),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['rates'] != null) {
        couriers.value = List<Map<String, dynamic>>.from(data['rates']);
      } else {
        couriers.clear();
      }
    } catch (e) {
      couriers.clear();
      Get.snackbar('Error', 'Failed to fetch rates', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingRates.value = false;
    }
  }

  Future<bool> createShipment(Map<String, dynamic> shipmentRequestBody) async {
    isCreatingShipment.value = true;
    try {
      final token = await StorageHelper.getToken();
      final deliveryId = await StorageHelper.box.read('currentDeliveryId') ?? '1';
      final apiUrl = ApiConfig.createShipment(deliveryId);
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(shipmentRequestBody),
      );
      final jsonResponse = jsonDecode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) && jsonResponse['success'] == true) {
        return true;
      } else {
        Get.snackbar('Error', jsonResponse['message'] ?? 'Failed to create shipment', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isCreatingShipment.value = false;
    }
  }
}
