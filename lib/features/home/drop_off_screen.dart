import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:starhills/model/courier_model.dart';
import '../../const/const.dart';
import '../../const/api_config.dart';
import 'drop_off_controller.dart';
import 'confirm_ride_screen.dart';
import 'shipment_sender_receiver_screen.dart';

class DropOffScreen extends StatelessWidget {
  const DropOffScreen({super.key, required this.selectedRider});

  final CourierModel selectedRider;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DropOffController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light background
      body: SafeArea(
        child: Column(
          children: [
            // Top Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              color: const Color(0xFFF8F9FA),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Center(
                        child: Text(
                          "Set Pickup & Drop-off",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Icon(Icons.help_outline),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  // Inputs
                  _buildGooglePlacesInputField(
                    controller: controller.pickupController,
                    icon: Icons.location_on_outlined,
                    iconColor: Colors.green,
                    hintText: "Enter Pickup Location",
                    onPlaceSelected:
                        (Prediction prediction, double? lat, double? lng) {
                          controller.setPickupLocation(
                            prediction.description ?? '',
                            lat: lat,
                            lng: lng,
                          );
                        },
                  ),
                  SizedBox(height: 15.h),
                  _buildGooglePlacesInputField(
                    controller: controller.dropoffController,
                    icon: Icons.location_on_outlined,
                    iconColor: Colors.red,
                    hintText: "Enter Drop-off Location",
                    onPlaceSelected:
                        (Prediction prediction, double? lat, double? lng) {
                          controller.setDropoffLocation(
                            prediction.description ?? '',
                            lat: lat,
                            lng: lng,
                          );
                        },
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),

            // Map Section
            Expanded(
              child: Stack(
                children: [
                  // Google Map
                  Positioned.fill(
                    child: Obx(() {
                      // Access markersVersion to trigger rebuild
                      controller.markersVersion.value;
                      return GoogleMap(
                        onMapCreated: controller.onMapCreated,
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(6.5244, 3.3792), // Lagos, Nigeria
                          zoom: 12,
                        ),
                        markers: controller.markers,
                        polylines: controller.polylines,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                      );
                    }),
                  ),
                  // Warning Banner
                  // Positioned(
                  //   bottom: 20.h,
                  //   left: 20.w,
                  //   right: 20.w,
                  //   child: Container(
                  //     padding: EdgeInsets.symmetric(
                  //       vertical: 12.h,
                  //       horizontal: 16.w,
                  //     ),
                  //     decoration: BoxDecoration(
                  //       color: const Color(0xFFFFF3CD), // Light yellow
                  //       borderRadius: BorderRadius.circular(8.r),
                  //       border: Border.all(color: const Color(0xFFFFECB5)),
                  //     ),
                  //     child: Row(
                  //       children: [
                  //         Icon(
                  //           Icons.warning_amber_rounded,
                  //           color: const Color(0xFF856404),
                  //           size: 24.sp,
                  //         ),
                  //         SizedBox(width: 10.w),
                  //         Expanded(
                  //           child: Text(
                  //             "Drop-off is outside service area.",
                  //             style: TextStyle(
                  //               color: const Color(0xFF856404),
                  //               fontSize: 14.sp,
                  //               fontWeight: FontWeight.w500,
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),

            // Bottom Section
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(Icons.access_time, "Est. time", "15 min"),
                      Container(
                        height: 40.h,
                        width: 1,
                        color: Colors.grey[300],
                      ),
                      _buildInfoItem(Icons.alt_route, "Distance", "2.5 miles"),
                      Container(
                        height: 40.h,
                        width: 1,
                        color: Colors.grey[300],
                      ),
                      _buildInfoItem(
                        Icons.payments_outlined,
                        "Fare",
                        "₦ 1,800",
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: Obx(() {
                      return ElevatedButton(
                        onPressed: controller.isCreatingDelivery.value
                            ? null
                            : () async {
                                if (controller.pickupLatLng.value == null ||
                                    controller.dropoffLatLng.value == null) {
                                  Get.snackbar(
                                    'Missing Information',
                                    'Please select both pickup and drop-off locations',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  return;
                                }

                                // Show validation progress dialog
                                Get.dialog(
                                  WillPopScope(
                                    onWillPop: () async => false,
                                    child: Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          15.r,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(20.w),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircularProgressIndicator(
                                              color: primaryColor,
                                            ),
                                            SizedBox(height: 20.h),
                                            Text(
                                              'Validating Addresses...',
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(height: 10.h),
                                            Text(
                                              'Please wait while we validate your pickup and drop-off locations',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  barrierDismissible: false,
                                );

                                // Validate pickup address
                                final pickupCode = await controller
                                    .validateAddress(
                                      controller.pickupController.text,
                                    );

                                if (pickupCode == null) {
                                  Get.back(); // Close dialog
                                  Get.snackbar(
                                    'Validation Failed',
                                    'Failed to validate pickup address. Please try again.',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  return;
                                }

                                // Validate dropoff address
                                final dropoffCode = await controller
                                    .validateAddress(
                                      controller.dropoffController.text,
                                    );

                                Get.back(); // Close dialog

                                if (dropoffCode == null) {
                                  Get.snackbar(
                                    'Validation Failed',
                                    'Failed to validate drop-off address. Please try again.',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  return;
                                }

                                // Store address codes
                                controller.pickupAddressCode.value = pickupCode;
                                controller.dropoffAddressCode.value =
                                    dropoffCode;

                                debugPrint(
                                  '[DropOffScreen] Pickup Address: ${controller.pickupController.text}',
                                );
                                debugPrint(
                                  '[DropOffScreen] Pickup Code: $pickupCode',
                                );
                                debugPrint(
                                  '[DropOffScreen] Drop-off Address: ${controller.dropoffController.text}',
                                );
                                debugPrint(
                                  '[DropOffScreen] Drop-off Code: $dropoffCode',
                                );

                                // Navigate to next screen with validated address codes
                                Get.to(
                                  () => ShipmentSenderReceiverScreen(
                                    senderAddress:
                                        controller.pickupController.text,
                                    receiverAddress:
                                        controller.dropoffController.text,
                                    senderAddressCode: pickupCode,
                                    receiverAddressCode: dropoffCode,
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: controller.isCreatingDelivery.value
                            ? SizedBox(
                                height: 20.h,
                                width: 20.w,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Continue",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGooglePlacesInputField({
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    required String hintText,
    required Function(Prediction, double?, double?) onPlaceSelected,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: GooglePlaceAutoCompleteTextField(
              textEditingController: controller,
              googleAPIKey: ApiConfig.googlePlacesApiKey,
              inputDecoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
              debounceTime: 800,
              countries: const ["ng"], // Restrict to Nigeria
              isLatLngRequired: true,
              getPlaceDetailWithLatLng: (Prediction prediction) {
                // Extract lat/lng from prediction
                double? lat = double.tryParse(prediction.lat ?? '');
                double? lng = double.tryParse(prediction.lng ?? '');
                onPlaceSelected(prediction, lat, lng);
              },
              itemClick: (Prediction prediction) {
                controller.text = prediction.description ?? "";
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: prediction.description?.length ?? 0),
                );
              },
              seperatedBuilder: Divider(color: Colors.grey[300], height: 1),
              containerHorizontalPadding: 10,
              itemBuilder: (context, index, Prediction prediction) {
                return Container(
                  padding: EdgeInsets.all(10.w),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey, size: 20.sp),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          prediction.description ?? "",
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: primaryColor, size: 24.sp),
        SizedBox(height: 5.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
