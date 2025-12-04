import 'dart:convert';

import 'package:get/get.dart';
import 'package:starhills/const/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:starhills/model/user_model.dart';
import 'package:starhills/utils/storage_helper.dart' as StorageHelper;
import 'package:starhills/utils/snackbar_helper.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var profile = UserModel().obs;

  @override
  void onInit() {
    super.onInit();
    getUserProfile();
  }

  getUserProfile() async {
    isLoading.value = true;
    try {
      var response = await http.get(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.profileMe),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${StorageHelper.getToken()}',
        },
      );
      print(response.body);
      print(StorageHelper.getToken());
      if (response.statusCode == 200) {
        profile.value = UserModel.fromJson(jsonDecode(response.body)['data']);
      } else {
        showSnackbar('Error', 'Failed to fetch profile', ContentType.failure);
      }
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }
}
