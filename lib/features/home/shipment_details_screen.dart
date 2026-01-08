import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:starhills/const/const.dart';
import 'package:starhills/features/home/shipment_controller.dart';
import 'package:starhills/models/user_shipment.dart';
import 'package:url_launcher/url_launcher.dart';

class ShipmentDetailsScreen extends StatelessWidget {
  const ShipmentDetailsScreen({super.key, required this.shipment});

  final UserShipment shipment;

  @override
  Widget build(BuildContext context) {
    // Attempt to find the controller, or use the one relevant to this flow if passed (but it's singleton usually)
    final ShipmentController controller = Get.find<ShipmentController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Shipment Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        // Use reactive shipment variable.
        // If the selectedShipment matches the passed shipment ID, us it. Otherwise default to passed shipment.
        // This ensures if we entered from a list item, we have data. If we refresh, we get new data.
        final reactiveShipment =
            (controller.selectedShipment.value != null &&
                controller.selectedShipment.value!.id == shipment.id)
            ? controller.selectedShipment.value!
            : shipment;

        // Overlay loading if needed, or replace body.
        // But better to use Stack if we want to show loading on top of content.
        // However, for simplicity given the prompt "cancel button", let's just show content.

        return Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  // Status and Tracking Number
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            _buildStatusBadge(reactiveShipment.status),
                          ],
                        ),
                        SizedBox(height: 15.h),
                        Divider(color: Colors.grey[200]),
                        SizedBox(height: 15.h),
                        _buildDetailRow(
                          'Tracking Number',
                          reactiveShipment.trackingNumber,
                          isBold: true,
                        ),
                        if (reactiveShipment.trackingUrl != null) ...[
                          SizedBox(height: 20.h),
                          SizedBox(
                            width: double.infinity,
                            height: 45.h,
                            child: ElevatedButton(
                              onPressed: () async {
                                final Uri url = Uri.parse(
                                  reactiveShipment.trackingUrl!,
                                );
                                if (!await launchUrl(
                                  url,
                                  mode: LaunchMode.externalApplication,
                                )) {
                                  Get.snackbar(
                                    'Error',
                                    'Could not open tracking URL',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                              child: Text(
                                'Track on Website',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Route Details
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Route Info',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            _buildIndicator(true),
                            SizedBox(width: 15.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sender',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  Text(
                                    reactiveShipment.senderName,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    reactiveShipment.senderAddress,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 7.w),
                          height: 30.h,
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Colors.grey[300]!,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            _buildIndicator(false),
                            SizedBox(width: 15.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Receiver',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  Text(
                                    reactiveShipment.receiverName,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    reactiveShipment.receiverAddress,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Package Details
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Package Details',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15.h),
                        _buildDetailRow(
                          'Amount',
                          '₦${reactiveShipment.amount.toStringAsFixed(2)}',
                        ),
                        SizedBox(height: 10.h),
                        _buildDetailRow(
                          'Date',
                          reactiveShipment.dateCreated.split('T')[0],
                        ),
                        SizedBox(height: 15.h),
                        Divider(color: Colors.grey[200]),
                        SizedBox(height: 10.h),
                        Text(
                          'Items',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 5.h),
                        ...reactiveShipment.items.map(
                          (item) => Padding(
                            padding: EdgeInsets.only(bottom: 5.h),
                            child: _buildDetailRow(
                              '${item.quantity}x ${item.name}',
                              '₦${item.price.toStringAsFixed(2)}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Cancel Button
                  if (reactiveShipment.status.toLowerCase() != 'cancelled' &&
                      reactiveShipment.status.toLowerCase() != 'delivered')
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.defaultDialog(
                            title: 'Cancel Shipment',
                            middleText:
                                'Are you sure you want to cancel this shipment?',
                            textConfirm: 'Yes, Cancel',
                            textCancel: 'No',
                            confirmTextColor: Colors.white,
                            buttonColor: Colors.red,
                            cancelTextColor: Colors.black,
                            onConfirm: () async {
                              Get.back(); // Close dialog
                              final success = await controller.cancelShipment(
                                reactiveShipment.trackingNumber,
                                reactiveShipment.id,
                              );
                              if (success) {
                                Get.snackbar(
                                  'Success',
                                  'Shipment cancelled successfully',
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text(
                          'Cancel Shipment',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
            if (controller.isCancellingShipment.value)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'success':
      case 'delivered':
      case 'completed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      case 'transit':
      case 'in_transit':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isStart) {
    return Container(
      width: 16.w,
      height: 16.w,
      decoration: BoxDecoration(
        color: isStart ? primaryColor : Colors.white,
        border: Border.all(color: primaryColor, width: 2),
        shape: BoxShape.circle,
      ),
      child: isStart
          ? null
          : Center(
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
    );
  }
}
