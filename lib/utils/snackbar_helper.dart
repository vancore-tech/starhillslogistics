import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSnackbar(String title, String message, ContentType contentType) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.transparent,
    barBlur: 0,
    overlayBlur: 0,
    snackStyle: SnackStyle.FLOATING,
    titleText: const SizedBox.shrink(),
    messageText: AwesomeSnackbarContent(
      title: title,
      message: message,
      contentType: contentType,
    ),
  );
}
