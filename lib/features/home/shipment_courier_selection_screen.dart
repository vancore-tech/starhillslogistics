import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'shipment_controller.dart';

class ShipmentCourierSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> rateRequestBody;
  const ShipmentCourierSelectionScreen({
    super.key,
    required this.rateRequestBody,
  });

  @override
  State<ShipmentCourierSelectionScreen> createState() => _ShipmentCourierSelectionScreenState();
}

class _ShipmentCourierSelectionScreenState extends State<ShipmentCourierSelectionScreen> {
  final ShipmentController controller = Get.put(ShipmentController());

  @override
  void initState() {
    super.initState();
    debugPrint('[ShipmentCourierSelectionScreen] rateRequestBody:');
    debugPrint(widget.rateRequestBody.toString());
    controller.fetchRates(widget.rateRequestBody);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Create New Shipment', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        debugPrint('[ShipmentCourierSelectionScreen] couriers:');
        debugPrint(controller.couriers.toString());
        return controller.isLoadingRates.value
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Step 3 of 3', style: TextStyle(fontSize: 13.sp, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                    SizedBox(height: 18.h),
                    Text('🚚 CHOOSE YOUR COURIER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                    SizedBox(height: 18.h),
                    Expanded(
                      child: ListView.builder(
                        itemCount: controller.couriers.length,
                        itemBuilder: (context, i) {
                          final courier = controller.couriers[i];
                          final selected = controller.selectedCourierIndex.value == i;
                          return GestureDetector(
                            onTap: () => controller.selectedCourierIndex.value = i,
                            child: Card(
                              color: selected ? const Color(0xFF3F4492) : Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              elevation: 1,
                              margin: EdgeInsets.only(bottom: 16.h),
                              child: Padding(
                                padding: EdgeInsets.all(16.w),
                                child: Row(
                                  children: [
                                    selected
                                        ? Icon(Icons.radio_button_checked, color: Colors.white)
                                        : Icon(Icons.radio_button_unchecked, color: Colors.grey),
                                    SizedBox(width: 12.w),
                                    if (courier['logo'] != null)
                                      Image.network(courier['logo'], height: 32.h, width: 32.w, fit: BoxFit.contain),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            courier['courier'] ?? '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15.sp,
                                              color: selected ? Colors.white : Colors.black,
                                            ),
                                          ),
                                          SizedBox(height: 6.h),
                                          Text(
                                            '₦${courier['price']}  •  ${courier['estimatedDays']} business days',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              color: selected ? Colors.white70 : Colors.grey[800],
                                            ),
                                          ),
                                          SizedBox(height: 6.h),
                                          // Placeholder for rating
                                          Text(
                                            '⭐⭐⭐⭐⭐ 4.8 (1,234 reviews)',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: selected ? Colors.white70 : Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                              side: const BorderSide(color: Color(0xFF3F4492)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                            ),
                            child: Text('Back', style: TextStyle(fontSize: 15.sp, color: const Color(0xFF3F4492))),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Obx(() => ElevatedButton(
                                onPressed: controller.selectedCourierIndex.value != null && !controller.isCreatingShipment.value
                                    ? () async {
                                        final courier = controller.couriers[controller.selectedCourierIndex.value!];
                                        final requestBody = Map<String, dynamic>.from(widget.rateRequestBody);
                                        requestBody['courier_id'] = courier['courier_id'] ?? courier['id'] ?? courier['courierId'];
                                        requestBody['service_code'] = courier['service_code'] ?? courier['serviceCode'];
                                        final success = await controller.createShipment(requestBody);
                                        if (success) {
                                          Get.snackbar('Success', 'Shipment created successfully!', backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
                                        }
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3F4492),
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                ),
                                child: controller.isCreatingShipment.value
                                    ? SizedBox(height: 20.h, width: 20.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Text('Create Shipment ✓', style: TextStyle(fontSize: 15.sp, color: Colors.white)),
                              ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
        
      }),
    );
  }
}
