import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:starhills/const/api_config.dart';
import 'package:starhills/model/shipment_statistics_model.dart';
import 'package:starhills/utils/storage_helper.dart' as StorageHelper;

class ShipmentStatisticsController extends GetxController {
  var isLoading = false.obs;
  var statistics = ShipmentStatisticsModel(
    total: 0,
    delivered: 0,
    inTransit: 0,
    cancelled: 0,
    revenue: 0,
    deliveryRate: 0,
  ).obs;

  @override
  void onInit() {
    super.onInit();
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    isLoading.value = true;
    try {
      final token = StorageHelper.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}shipments/statistics'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['statistics'] != null) {
          statistics.value = ShipmentStatisticsModel.fromJson(data['statistics']);
        }
      }
    } catch (e) {
      print('Error fetching shipment statistics: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
