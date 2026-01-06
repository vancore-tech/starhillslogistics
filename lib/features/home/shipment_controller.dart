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
  var requestToken = ''.obs;
  var checkoutData = Rx<Map<String, dynamic>?>(null);

  // Insurance
  var insuranceOptions = <Map<String, dynamic>>[].obs;
  var isLoadingInsurance = false.obs;

  Future<void> fetchInsuranceRates() async {
    if (requestToken.value.isEmpty) {
      Get.snackbar('Error', 'Request token missing');
      return;
    }
    isLoadingInsurance.value = true;
    try {
      final token = await StorageHelper.getToken();
      debugPrint(
        '[ShipmentController] Fetching insurance rates with token: ${requestToken.value}',
      );

      final request = http.Request(
        'GET',
        Uri.parse('${ApiConfig.baseUrl}packages/insurance-rates'),
      );
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      request.body = jsonEncode({'request_token': requestToken.value});

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('[ShipmentController] Insurance response: ${response.body}');
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['result'] != null) {
        insuranceOptions.value = List<Map<String, dynamic>>.from(
          data['result'],
        );
      } else {
        insuranceOptions.clear();
        Get.snackbar(
          'Error',
          data['message'] ?? 'Failed to fetch insurance options',
        );
      }
    } catch (e) {
      debugPrint('[ShipmentController] Error fetching insurance: $e');
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoadingInsurance.value = false;
    }
  }

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

        // Save request_token
        if (data['data']['data']['request_token'] != null) {
          requestToken.value = data['data']['data']['request_token'];
          debugPrint(
            '[ShipmentController] Saved request_token: ${requestToken.value}',
          );
        }

        // Save checkout_data for sender/receiver info
        if (data['data']['data']['checkout_data'] != null) {
          checkoutData.value = data['data']['data']['checkout_data'];
          debugPrint('[ShipmentController] Saved checkout_data');
        }

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

  Future<bool> createShipment(Map<String, dynamic> shipmentData) async {
    isCreatingShipment.value = true;
    try {
      final token = await StorageHelper.getToken();

      // Validate we have the request_token
      if (requestToken.value.isEmpty) {
        Get.snackbar(
          'Error',
          'Missing request token. Please recalculate rates.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      // Get checkout data for sender info
      final shipFrom = checkoutData.value?['ship_from'];

      // Prepare request body
      // We need to merge the calculated checkout_data with user inputs
      // and the selected courier/insurance info.

      // The structure seems to be:
      // {
      //   ... checkout_data fields (sender/receiver info) ...
      //   ... user inputs (category, dimension etc) ...
      //   request_token: ...
      //   service_code: ... (selected courier)
      //   insurance_code: ... (selected insurance)
      //   courier_id: ...
      // }

      final requestBody = <String, dynamic>{
        'request_token': requestToken.value,
        'service_code': shipmentData['service_code'],
        'courier_id': shipmentData['courier_id'],
        'insurance_code':
            shipmentData['insurance_code'], // Added insurance code logic
        'amount': shipmentData['amount'],
      };

      // Add sender/receiver details if they need to be passed explicitly
      // However, usually 'request_token' + 'service_code' might be enough if the backend cached the data.
      // But looking at previous code, we were adding sender/receiver details.
      // Let's keep adding them to be safe, filtering from shipmentData/checkoutData.

      if (checkoutData.value != null) {
        final shipFrom = checkoutData.value!['ship_from'];
        if (shipFrom != null) {
          requestBody['sender_name'] = shipFrom['name'];
          requestBody['sender_email'] = shipFrom['email'];
          requestBody['sender_phone'] = shipFrom['phone'];
          requestBody['sender_street'] = shipFrom['street1'];
          requestBody['sender_city'] = shipFrom['city'];
          if (shipFrom['state'] != null &&
              shipFrom['state'].toString().isNotEmpty) {
            requestBody['sender_state'] = shipFrom['state'];
          }
        }
      }

      // Receiver information from user input (shipmentData)
      requestBody['receiver_name'] = shipmentData['receiver_name'];
      requestBody['receiver_phone'] = shipmentData['receiver_phone'];
      requestBody['receiver_email'] = shipmentData['receiver_email'];
      requestBody['receiver_street'] = shipmentData['receiver_address'];
      requestBody['receiver_city'] = shipmentData['receiver_city'];
      requestBody['receiver_state'] = shipmentData['receiver_state'];
      requestBody['receiver_country'] = shipmentData['receiver_country'];

      // Add dimension object if available
      if (shipmentData['package_dimension'] != null) {
        requestBody['package_dimension'] = shipmentData['package_dimension'];
      }

      // Add category (ID) if available
      if (shipmentData['category_id'] != null) {
        requestBody['category'] = shipmentData['category_id'];
      }

      // Add COD if available
      if (shipmentData['cod_amount'] != null) {
        requestBody['cod_amount'] = shipmentData['cod_amount'];
      }

      debugPrint('[ShipmentController] Creating shipment with body:');
      debugPrint(const JsonEncoder.withIndent('  ').convert(requestBody));

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}shipments/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint(
        '[ShipmentController] Create shipment response status: ${response.statusCode}',
      );
      debugPrint(
        '[ShipmentController] Create shipment response body: ${response.body}',
      );

      final jsonResponse = jsonDecode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          jsonResponse['success'] == true) {
        // Show success with tracking number if available
        final trackingNumber = jsonResponse['trackingNumber'];
        final waybillUrl = jsonResponse['waybillUrl'];

        debugPrint(
          '[ShipmentController] Shipment created! Tracking: $trackingNumber',
        );
        if (waybillUrl != null) {
          debugPrint('[ShipmentController] Waybill URL: $waybillUrl');
        }

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
      debugPrint('[ShipmentController] Error creating shipment: $e');
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

  /// Helper method to extract city from address string
  String? _extractCityFromAddress(String address) {
    // Common Nigerian cities
    final cities = [
      'Lagos',
      'Abuja',
      'Ikeja',
      'Victoria Island',
      'Lekki',
      'Ikoyi',
      'Surulere',
      'Yaba',
      'Ajah',
      'Festac',
      'Kano',
      'Ibadan',
      'Port Harcourt',
      'Benin',
      'Kaduna',
    ];

    final lowerAddress = address.toLowerCase();
    for (final city in cities) {
      if (lowerAddress.contains(city.toLowerCase())) {
        return city;
      }
    }
    return null;
  }

  /// Helper method to extract state from address string
  String? _extractStateFromAddress(String address) {
    // Map of common patterns to states
    final statePatterns = {
      'lagos': 'Lagos',
      'abuja': 'FCT',
      'fct': 'FCT',
      'ikeja': 'Lagos',
      'victoria island': 'Lagos',
      'lekki': 'Lagos',
      'ikoyi': 'Lagos',
      'surulere': 'Lagos',
      'yaba': 'Lagos',
      'ajah': 'Lagos',
      'festac': 'Lagos',
      'kano': 'Kano',
      'ibadan': 'Oyo',
      'port harcourt': 'Rivers',
      'benin': 'Edo',
      'kaduna': 'Kaduna',
    };

    final lowerAddress = address.toLowerCase();
    for (final pattern in statePatterns.entries) {
      if (lowerAddress.contains(pattern.key)) {
        return pattern.value;
      }
    }
    return null;
  }
}
