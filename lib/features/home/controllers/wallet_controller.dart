import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:starhills/const/api_config.dart';
import 'package:starhills/utils/storage_helper.dart' as StorageHelper;

class WalletController extends GetxController {
  var isLoading = false.obs;
  var balance = 0.0.obs;
  var currency = 'NGN'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBalance();
  }

  Future<void> fetchBalance() async {
    isLoading.value = true;
    try {
      final token = StorageHelper.getToken();
      final response = await http.get(
        Uri.parse(ApiConfig.baseUrl + 'wallet/balance'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          balance.value = (data['balance'] ?? 0).toDouble();
          currency.value = data['currency'] ?? 'NGN';
        }
      }
    } catch (e) {
      print('Error fetching wallet balance: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
