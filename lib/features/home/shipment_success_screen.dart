import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../const/const.dart';
import 'main_layout.dart';

class ShipmentSuccessScreen extends StatelessWidget {
  const ShipmentSuccessScreen({super.key, required this.shipmentData});

  final Map<String, dynamic> shipmentData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40.h),
                // Success Animation/Icon
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60.sp,
                  ),
                ),
                SizedBox(height: 20.h),

                // Success Message
                Text(
                  'Shipment Created Successfully!',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.h),

                Text(
                  shipmentData['data']?['message'] ??
                      'Your shipment has been created and is ready for pickup.',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.h),

                // Shipment Details Card
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(15.r),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        'Order ID',
                        shipmentData['data']?['data']?['order_id']
                                ?.toString() ??
                            'N/A',
                      ),
                      SizedBox(height: 12.h),
                      _buildDetailRow(
                        'Tracking Number',
                        shipmentData['trackingNumber']?.toString() ?? 'N/A',
                      ),
                      SizedBox(height: 12.h),
                      _buildDetailRow(
                        'Courier',
                        shipmentData['data']?['data']?['courier']?['name']
                                ?.toString() ??
                            'N/A',
                      ),
                      SizedBox(height: 12.h),
                      Divider(color: Colors.grey[300]),
                      SizedBox(height: 12.h),
                      _buildInfoSection(
                        'Sender',
                        shipmentData['data']?['data']?['ship_from']?['name'] ??
                            '',
                        shipmentData['data']?['data']?['ship_from']?['address'] ??
                            '',
                      ),
                      SizedBox(height: 16.h),
                      _buildInfoSection(
                        'Receiver',
                        shipmentData['data']?['data']?['ship_to']?['name'] ??
                            '',
                        shipmentData['data']?['data']?['ship_to']?['address'] ??
                            '',
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),

                // Buttons
                if (shipmentData['data']?['data']?['tracking_url'] != null)
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.offAll(() => const MainLayout());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'Track Shipment',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (shipmentData['data']?['data']?['tracking_url'] != null)
                  SizedBox(height: 12.h),

                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.offAll(() => const MainLayout());
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, String name, String address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          name,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        if (address.isNotEmpty)
          Text(
            address,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}
