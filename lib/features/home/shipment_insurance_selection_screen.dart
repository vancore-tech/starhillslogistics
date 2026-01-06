import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'shipment_controller.dart';
import 'shipment_courier_selection_screen.dart';

class ShipmentInsuranceSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> rateRequestBody;
  const ShipmentInsuranceSelectionScreen({
    super.key,
    required this.rateRequestBody,
  });

  @override
  State<ShipmentInsuranceSelectionScreen> createState() =>
      _ShipmentInsuranceSelectionScreenState();
}

class _ShipmentInsuranceSelectionScreenState
    extends State<ShipmentInsuranceSelectionScreen> {
  final ShipmentController controller = Get.find<ShipmentController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchInsuranceRates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Select Insurance',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        if (controller.isLoadingInsurance.value) {
          return Center(
            child: CircularProgressIndicator(color: const Color(0xFF3F4492)),
          );
        }
        if (controller.insuranceOptions.isEmpty) {
          return Center(child: Text('No insurance options available.'));
        }
        return ListView.separated(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.insuranceOptions.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final insurance = controller.insuranceOptions[index];
            return _buildInsuranceCard(insurance);
          },
        );
      }),
    );
  }

  Widget _buildInsuranceCard(Map<String, dynamic> insurance) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to Courier Selection, pass selected insurance code
          // and skip fetchRates since we presumably did it before insurance
          Get.to(
            () => ShipmentCourierSelectionScreen(
              rateRequestBody: widget.rateRequestBody,
              insuranceCode: insurance['code'],
              skipFetchRates: true,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      insurance['insurer'] ?? 'Insurance',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  Text(
                    '₦${insurance['amount']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: const Color(0xFF3F4492),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              if (insurance['policy_condition'] != null)
                Text(
                  // Strip HTML tags roughly
                  insurance['policy_condition'].toString().replaceAll(
                    RegExp(r'<[^>]*>'),
                    '',
                  ),
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
