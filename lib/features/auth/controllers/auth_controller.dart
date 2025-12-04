import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starhills/const/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:starhills/features/auth/verification_screen.dart';
import 'package:starhills/features/auth/verification_success_screen.dart';
import 'package:starhills/features/home/controllers/profile_controller.dart';
import 'package:starhills/features/home/main_layout.dart';
import 'package:starhills/utils/snackbar_helper.dart';
import 'package:starhills/utils/storage_helper.dart' as StorageHelper;

class AuthController extends GetxController {
  var isLoading = false.obs;

  register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    isLoading.value = true;
    try {
      var response = await http.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'fullName': fullName,
          'phone': phoneNumber,
        }),
      );

      if (response.statusCode == 201) {
        showSnackbar(
          'Success',
          'Please Verify Your Email Address',
          ContentType.success,
        );

        var data = jsonDecode(response.body);
        print(data);

        StorageHelper.saveToken(data['accessToken']);

        Navigator.of(Get.context!).push(
          MaterialPageRoute(
            builder: (context) => VerificationScreen(email: email),
          ),
        );
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        showSnackbar(
          'Error',
          data['message'] ?? 'Failed to register',
          ContentType.failure,
        );
      } else {
        debugPrint(response.body);
        showSnackbar('Error', 'Failed to register', ContentType.failure);
      }
    } catch (e) {
      debugPrint(e.toString());
      showSnackbar('Error', 'An error occurred', ContentType.failure);
    } finally {
      isLoading.value = false;
    }
  }

  verifyOtp({required String email, required String otp}) async {
    isLoading.value = true;
    try {
      var response = await http.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.verifyOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        showSnackbar(
          'Success',
          'Account Created Successfully',
          ContentType.success,
        );

        var data = jsonDecode(response.body);
        print(data);

        StorageHelper.saveToken(data['token']['accessToken']);
        StorageHelper.saveUserId(data['user']['id']);

        Navigator.of(Get.context!).push(
          MaterialPageRoute(builder: (context) => VerificationSuccessScreen()),
        );
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        print(data);
        showSnackbar(
          'Error',
          data['message'] ?? 'Error verifying email address',
          ContentType.failure,
        );
      } else {
        debugPrint(response.body);
        showSnackbar(
          'Error',
          'Error verifying email address',
          ContentType.failure,
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      showSnackbar('Error', 'An error occurred', ContentType.failure);
    } finally {
      isLoading.value = false;
    }
  }

  resendOtp({required String email}) async {
    isLoading.value = true;
    try {
      var response = await http.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.resendOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        showSnackbar('Success', 'OTP Resent Successfully', ContentType.success);
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        showSnackbar(
          'Error',
          data['message'] ?? 'Error resending OTP',
          ContentType.failure,
        );
      } else {
        debugPrint(response.body);
        showSnackbar('Error', 'Error resending OTP', ContentType.failure);
      }
    } catch (e) {
      debugPrint(e.toString());
      showSnackbar('Error', 'An error occurred', ContentType.failure);
    } finally {
      isLoading.value = false;
    }
  }

  login({required String email, required String password}) async {
    isLoading.value = true;
    try {
      var response = await http.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        showSnackbar('Success', 'Login Successful', ContentType.success);

        var data = jsonDecode(response.body);
        print(data);

        StorageHelper.saveToken(data['accessToken']);
        StorageHelper.saveUserId(data['user']['id']);

        // fetch profile from profileController
        ProfileController().getUserProfile();

        Navigator.of(
          Get.context!,
        ).push(MaterialPageRoute(builder: (context) => MainLayout()));
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        showSnackbar(
          'Error',
          data['message'] ?? 'Error logging in',
          ContentType.failure,
        );
      } else {
        debugPrint(response.body);
        showSnackbar('Error', 'Error logging in', ContentType.failure);
      }
    } catch (e) {
      debugPrint(e.toString());
      showSnackbar('Error', 'An error occurred', ContentType.failure);
    } finally {
      isLoading.value = false;
    }
  }

  clearToken() {
    StorageHelper.clearToken();
  }
}
