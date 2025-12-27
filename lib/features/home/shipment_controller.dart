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
      debugPrint(
        '[ShipmentController] fetchRates response status: ${response.statusCode}',
      );
      debugPrint(
        '[ShipmentController] fetchRates response body: ${response.body}',
      );

      final data = jsonDecode(response.body);

      // Parse the nested response structure
      if (data['success'] == true &&
          data['data'] != null &&
          data['data']['data'] != null &&
          data['data']['data']['couriers'] != null) {
        couriers.value = List<Map<String, dynamic>>.from(
          data['data']['data']['couriers'],
        );
        debugPrint('[ShipmentController] Parsed ${couriers.length} couriers');
      } else if (data['success'] == true && data['rates'] != null) {
        // Fallback for old response format
        couriers.value = List<Map<String, dynamic>>.from(data['rates']);
        debugPrint(
          '[ShipmentController] Parsed ${couriers.length} couriers (old format)',
        );
      } else {
        couriers.clear();
        debugPrint('[ShipmentController] No couriers found in response');
      }
    } catch (e) {
      debugPrint('[ShipmentController] Error fetching rates: $e');
      couriers.clear();
      Get.snackbar(
        'Error',
        'Failed to fetch rates: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingRates.value = false;
    }
  }

  Future<bool> createShipment(Map<String, dynamic> shipmentRequestBody) async {
    isCreatingShipment.value = true;
    try {
      final token = await StorageHelper.getToken();
      final deliveryId =
          await StorageHelper.box.read('currentDeliveryId') ?? '1';
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
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          jsonResponse['success'] == true) {
        return true;
      } else {
        Get.snackbar(
          'Error',
          jsonResponse['message'] ?? 'Failed to create shipment',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isCreatingShipment.value = false;
    }
  }
}
