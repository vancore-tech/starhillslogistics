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
      final token = StorageHelper.getToken();
      print('Fetching profile with token: $token');

      var response = await http.get(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.profileMe),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Profile response status: ${response.statusCode}');
      print('Profile response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed profile data: $data');

        // Use new user response structure
        profile.value = UserModel.fromJson(data['user'] ?? data['data']);

        // Save user data to storage for later use
        if (profile.value.fullName != null) {
          StorageHelper.box.write('userName', profile.value.fullName);
        }
        if (profile.value.email != null) {
          StorageHelper.box.write('userEmail', profile.value.email);
        }
        if (profile.value.phone != null) {
          StorageHelper.box.write('userPhone', profile.value.phone);
        }

        print('Profile loaded successfully: ${profile.value.fullName}');
      } else {
        print('Failed to fetch profile: ${response.statusCode}');
        showSnackbar('Error', 'Failed to fetch profile', ContentType.failure);
      }
    } catch (e) {
      print('Error fetching profile: $e');
      showSnackbar(
        'Error',
        'An error occurred while fetching profile',
        ContentType.failure,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
