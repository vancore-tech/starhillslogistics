import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:starhills/const/api_config.dart';
import 'package:starhills/model/rate_courier_model.dart';
import 'package:starhills/utils/storage_helper.dart' as StorageHelper;
import '../../const/const.dart';
import 'shipment_success_screen.dart';
import 'drop_off_controller.dart';

class RateCouriersScreen extends StatefulWidget {
  const RateCouriersScreen({
    super.key,
    required this.couriers,
    required this.requestToken,
    required this.packageData,
  });

  final List<RateCourierModel> couriers;
  final String requestToken;
  final Map<String, dynamic> packageData;

  @override
  State<RateCouriersScreen> createState() => _RateCouriersScreenState();
}

class _RateCouriersScreenState extends State<RateCouriersScreen> {
  int? _selectedCourierIndex;
  bool _isCreatingShipment = false;

  Future<void> _createShipment(RateCourierModel courier) async {
    setState(() {
      _isCreatingShipment = true;
    });

    try {
      final token = StorageHelper.getToken();
      final controller = Get.find<DropOffController>();

      // Get delivery ID from storage or create delivery first
      final deliveryId = StorageHelper.box.read('currentDeliveryId') ?? '1';

      final requestBody = <String, dynamic>{
        'sender_address_code': widget.packageData['sender_address_code'],
        'reciever_address_code': widget.packageData['reciever_address_code'],
        'pickup_date': widget.packageData['pickup_date'],
        'category_id': widget.packageData['category_id'],
        'package_items': widget.packageData['package_items'],
        'package_dimension': widget.packageData['package_dimension'],
        'service_type': widget.packageData['service_type'],
        'delivery_instructions': widget.packageData['delivery_instructions'],
        'request_token': widget.requestToken,
        'pickup_address': controller.selectedPickupLocation.value,
        'courier_id': courier.courierId,
        'service_code': courier.serviceCode,
      };

      debugPrint('Creating shipment with data:');
      debugPrint(jsonEncode(requestBody));

      var response = await http.post(
        Uri.parse(ApiConfig.createShipment(deliveryId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('Create shipment response status: ${response.statusCode}');

      // Format JSON response for better readability in console
      try {
        final jsonResponse = jsonDecode(response.body);
        const encoder = JsonEncoder.withIndent('  ');
        final formattedResponse = encoder.convert(jsonResponse);
        debugPrint(
          'Create shipment response body (formatted):\n$formattedResponse',
        );
      } catch (e) {
        debugPrint('Create shipment response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true) {
          // Extract shipment data safely
          final shipmentData = jsonResponse['data'] is Map<String, dynamic>
              ? jsonResponse['data'] as Map<String, dynamic>
              : <String, dynamic>{};

          // Navigate to success screen
          Get.off(() => ShipmentSuccessScreen(shipmentData: shipmentData));
        } else {
          Get.snackbar(
            'Error',
            jsonResponse['message'] ?? 'Failed to create shipment',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        // Parse error response
        String errorMessage =
            'Failed to create shipment: ${response.statusCode}';
        try {
          final jsonResponse = jsonDecode(response.body);
          errorMessage = jsonResponse['message'] ?? errorMessage;
        } catch (e) {
          // If response is not JSON, use default message
        }

        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      debugPrint('Error creating shipment: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        _isCreatingShipment = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Available Couriers',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Info Banner
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: primaryColor, size: 20.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    '${widget.couriers.length} couriers available for your delivery',
                    style: TextStyle(color: Colors.black87, fontSize: 13.sp),
                  ),
                ),
              ],
            ),
          ),

          // Couriers List
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              itemCount: widget.couriers.length,
              separatorBuilder: (context, index) => SizedBox(height: 15.h),
              itemBuilder: (context, index) {
                final courier = widget.couriers[index];
                return _buildCourierCard(courier, index);
              },
            ),
          ),

          // Bottom Button
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton(
                onPressed: _selectedCourierIndex != null && !_isCreatingShipment
                    ? () {
                        final selectedCourier =
                            widget.couriers[_selectedCourierIndex!];
                        _createShipment(selectedCourier);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  elevation: 0,
                ),
                child: _isCreatingShipment
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Create Shipment',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourierCard(RateCourierModel courier, int index) {
    final isSelected = _selectedCourierIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCourierIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: isSelected
              ? Border.all(color: primaryColor, width: 2)
              : Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Courier Image
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10.r),
                    image: courier.courierImage != null
                        ? DecorationImage(
                            image: NetworkImage(courier.courierImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: courier.courierImage == null
                      ? Icon(
                          Icons.local_shipping,
                          color: Colors.grey[600],
                          size: 24.sp,
                        )
                      : null,
                ),
                SizedBox(width: 15.w),

                // Courier Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        courier.courierName ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 14.sp),
                          SizedBox(width: 4.w),
                          Text(
                            '${courier.ratings?.toStringAsFixed(1) ?? "N/A"} (${courier.votes ?? 0} votes)',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₦ ${courier.total?.toStringAsFixed(2) ?? "0.00"}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    if (courier.discount != null &&
                        (courier.discount!.percentage ?? 0) > 0)
                      Container(
                        margin: EdgeInsets.only(top: 4.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          '${courier.discount!.percentage}% OFF',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(color: Colors.grey[200], height: 1),
            SizedBox(height: 12.h),

            // Delivery Info
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    Icons.schedule,
                    'Pickup',
                    courier.pickupEta ?? 'N/A',
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _buildInfoChip(
                    Icons.local_shipping,
                    'Delivery',
                    courier.deliveryEta ?? 'N/A',
                    Colors.green,
                  ),
                ),
              ],
            ),

            // Tracking Info
            if (courier.tracking != null) ...[
              SizedBox(height: 10.h),
              Row(
                children: [
                  Icon(
                    Icons.location_searching,
                    size: 14.sp,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Tracking: ${courier.tracking!.label ?? "N/A"}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(width: 8.w),
                  ...List.generate(
                    5,
                    (i) => Container(
                      width: 8.w,
                      height: 8.w,
                      margin: EdgeInsets.only(right: 2.w),
                      decoration: BoxDecoration(
                        color: i < (courier.tracking!.bars ?? 0)
                            ? Colors.amber
                            : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Badges
            SizedBox(height: 10.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: [
                if (courier.onDemand == true)
                  _buildBadge('On-Demand', Colors.orange),
                if (courier.waybill == true)
                  _buildBadge('Waybill', Colors.purple),
                if (courier.isCodAvailable == true)
                  _buildBadge('COD Available', Colors.teal),
              ],
            ),

            // Select Button
            if (isSelected) ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: primaryColor, size: 18.sp),
                    SizedBox(width: 6.w),
                    Text(
                      'Selected',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12.sp, color: color),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
