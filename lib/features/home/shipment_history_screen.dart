import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:starhills/const/const.dart';
import 'package:starhills/features/home/shipment_controller.dart';
import 'package:starhills/features/home/shipment_details_screen.dart';
import 'package:starhills/models/user_shipment.dart';
// import 'package:intl/intl.dart';

class ShipmentHistoryScreen extends StatefulWidget {
  const ShipmentHistoryScreen({super.key});

  @override
  State<ShipmentHistoryScreen> createState() => _ShipmentHistoryScreenState();
}

class _ShipmentHistoryScreenState extends State<ShipmentHistoryScreen> {
  final ShipmentController controller = Get.put(ShipmentController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchUserShipments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'My Shipments',
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
        return Stack(
          children: [
            if (controller.isLoadingShipments.value)
              const Center(
                child: CircularProgressIndicator(color: primaryColor),
              )
            else if (controller.userShipments.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 60.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'No shipments found',
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              RefreshIndicator(
                onRefresh: controller.fetchUserShipments,
                color: primaryColor,
                child: ListView.separated(
                  padding: EdgeInsets.all(15.w),
                  itemCount: controller.userShipments.length,
                  separatorBuilder: (context, index) => SizedBox(height: 15.h),
                  itemBuilder: (context, index) {
                    final shipment = controller.userShipments[index];
                    return GestureDetector(
                      onTap: () async {
                        debugPrint(
                          'Tapped shipment ${shipment.id}, fetching details...',
                        );
                        final success = await controller.fetchShipmentDetails(
                          shipment.id,
                        );
                        if (success &&
                            controller.selectedShipment.value != null) {
                          Get.to(
                            () => ShipmentDetailsScreen(
                              shipment: controller.selectedShipment.value!,
                            ),
                          );
                        }
                      },
                      child: _buildShipmentCard(shipment),
                    );
                  },
                ),
              ),

            // Loading Overlay
            if (controller.isLoadingShipmentDetails.value)
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

  Widget _buildShipmentCard(UserShipment shipment) {
    return Container(
      padding: EdgeInsets.all(15.w),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tracking: ${shipment.trackingNumber}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
              _buildStatusBadge(shipment.status),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      shipment.senderCity.isNotEmpty
                          ? shipment.senderCity
                          : 'N/A',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: Colors.grey[400], size: 20.sp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'To',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      shipment.receiverCity.isNotEmpty
                          ? shipment.receiverCity
                          : 'N/A',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: Colors.grey[200]),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount: ₦${shipment.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              // Text(
              //   DateFormat('MMM dd, yyyy').format(DateTime.parse(shipment.dateCreated)),
              //   style: TextStyle(
              //     fontSize: 12.sp,
              //     color: Colors.grey[600],
              //   ),
              // ),
            ],
          ),
        ],
      ),
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
}
