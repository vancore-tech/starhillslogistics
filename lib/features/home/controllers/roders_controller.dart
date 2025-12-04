import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:starhills/const/api_config.dart';
import 'package:starhills/model/courier_model.dart';
import 'package:starhills/utils/storage_helper.dart' as StorageHelper;

class RidersController extends GetxController {
  var isLoading = false.obs;
  var riders = <CourierModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getRiders();
  }

  getRiders() async {
    isLoading.value = true;
    try {
      var response = await http.get(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.fetchCouriers),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${StorageHelper.getToken()}',
        },
      );
      if (response.statusCode == 200) {
        riders.value = [];
        var ridersData = jsonDecode(response.body)['data'] as List;
        riders.value = ridersData.map((e) => CourierModel.fromJson(e)).toList();
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }
}
