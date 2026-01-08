import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'shipment_controller.dart';
import 'shipment_success_screen.dart';

class ShipmentCourierSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> rateRequestBody;
  final String? insuranceCode;
  final bool skipFetchRates;

  const ShipmentCourierSelectionScreen({
    super.key,
    required this.rateRequestBody,
    this.insuranceCode,
    this.skipFetchRates = false,
  });

  @override
  State<ShipmentCourierSelectionScreen> createState() =>
      _ShipmentCourierSelectionScreenState();
}

class _ShipmentCourierSelectionScreenState
    extends State<ShipmentCourierSelectionScreen> {
  final ShipmentController controller = Get.put(ShipmentController());
  String selectedFilter = 'all'; // all, fastest, cheapest

  @override
  void initState() {
    super.initState();
    debugPrint('[ShipmentCourierSelectionScreen] rateRequestBody:');
    debugPrint(widget.rateRequestBody.toString());

    if (!widget.skipFetchRates) {
      controller.fetchRates(widget.rateRequestBody);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Choose Your Courier',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        if (controller.isLoadingRates.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: const Color(0xFF3F4492)),
                SizedBox(height: 16.h),
                Text(
                  'Finding best couriers for you...',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final couriers = controller.couriers;
        final fastestCourier = _getFastestCourier(couriers);
        final cheapestCourier = _getCheapestCourier(couriers);

        return Column(
          children: [
            // Filter Chips
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              color: Colors.white,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all', couriers.length),
                  SizedBox(width: 8.w),
                  _buildFilterChip('Fastest', 'fastest', 1),
                  SizedBox(width: 8.w),
                  _buildFilterChip('Cheapest', 'cheapest', 1),
                ],
              ),
            ),

            // Couriers List
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(20.w),
                children: [
                  Text(
                    'Step 3 of 3',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Show filtered couriers
                  ..._getFilteredCouriers(
                    couriers,
                    fastestCourier,
                    cheapestCourier,
                  ).asMap().entries.map((entry) {
                    final index = entry.key;
                    final courier = entry.value;
                    final isFastest =
                        courier['courier_id'] == fastestCourier?['courier_id'];
                    final isCheapest =
                        courier['courier_id'] == cheapestCourier?['courier_id'];

                    return _buildCourierCard(
                      courier,
                      index,
                      isFastest: isFastest,
                      isCheapest: isCheapest,
                    );
                  }).toList(),

                  SizedBox(height: 80.h), // Space for bottom button
                ],
              ),
            ),

            // Bottom Action Button
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        side: const BorderSide(color: Color(0xFF3F4492)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: const Color(0xFF3F4492),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 2,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed:
                            controller.selectedCourierIndex.value != null &&
                                !controller.isCreatingShipment.value
                            ? () async {
                                final courier =
                                    couriers[controller
                                        .selectedCourierIndex
                                        .value!];
                                final requestBody = Map<String, dynamic>.from(
                                  widget.rateRequestBody,
                                );
                                requestBody['courier_id'] =
                                    courier['courier_id'];
                                requestBody['service_code'] =
                                    courier['service_code'];
                                requestBody['amount'] = courier['total'];

                                // Add insurance code if available
                                if (widget.insuranceCode != null) {
                                  requestBody['insurance_code'] =
                                      widget.insuranceCode;
                                }

                                final result = await controller.createShipment(
                                  requestBody,
                                );
                                if (result != null) {
                                  Get.snackbar(
                                    'Success',
                                    'Shipment created successfully!',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );

                                  // Navigate to success screen
                                  Get.off(
                                    () => ShipmentSuccessScreen(
                                      shipmentData: result,
                                    ),
                                  );
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F4492),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: controller.isCreatingShipment.value
                            ? SizedBox(
                                height: 20.h,
                                width: 20.w,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Create Shipment ✓',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3F4492) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF3F4492) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            SizedBox(width: 6.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredCouriers(
    List<Map<String, dynamic>> couriers,
    Map<String, dynamic>? fastest,
    Map<String, dynamic>? cheapest,
  ) {
    if (selectedFilter == 'fastest' && fastest != null) {
      return [fastest];
    } else if (selectedFilter == 'cheapest' && cheapest != null) {
      return [cheapest];
    }
    return couriers;
  }

  Map<String, dynamic>? _getFastestCourier(
    List<Map<String, dynamic>> couriers,
  ) {
    if (couriers.isEmpty) return null;
    return couriers.reduce((a, b) {
      final aEta = a['delivery_eta'] ?? '';
      final bEta = b['delivery_eta'] ?? '';
      // Simple comparison - in production, parse the ETA properly
      return aEta.compareTo(bEta) < 0 ? a : b;
    });
  }

  Map<String, dynamic>? _getCheapestCourier(
    List<Map<String, dynamic>> couriers,
  ) {
    if (couriers.isEmpty) return null;
    return couriers.reduce((a, b) {
      final aTotal = (a['total'] ?? 0).toDouble();
      final bTotal = (b['total'] ?? 0).toDouble();
      return aTotal < bTotal ? a : b;
    });
  }

  Widget _buildCourierCard(
    Map<String, dynamic> courier,
    int index, {
    bool isFastest = false,
    bool isCheapest = false,
  }) {
    final selected = controller.selectedCourierIndex.value == index;
    final discount = courier['discount'];
    final hasDiscount = discount != null && discount['percentage'] > 0;
    final tracking = courier['tracking'];
    final ratings = courier['ratings'] ?? 0.0;
    final votes = courier['votes'] ?? 0;

    return GestureDetector(
      onTap: () => controller.selectedCourierIndex.value = index,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? const Color(0xFF3F4492) : Colors.grey[200]!,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: const Color(0xFF3F4492).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          children: [
            // Badges Row
            if (isFastest || isCheapest || hasDiscount)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                ),
                child: Row(
                  children: [
                    if (isFastest) ...[
                      Icon(Icons.flash_on, color: Colors.orange, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text(
                        'Fastest',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.orange[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isCheapest || hasDiscount) SizedBox(width: 8.w),
                    ],
                    if (isCheapest) ...[
                      Icon(Icons.local_offer, color: Colors.green, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text(
                        'Cheapest',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (hasDiscount) SizedBox(width: 8.w),
                    ],
                    if (hasDiscount) ...[
                      Icon(Icons.discount, color: Colors.red, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text(
                        '${discount['percentage']}% OFF',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.red[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // Main Content
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Radio Button
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: selected ? const Color(0xFF3F4492) : Colors.grey,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),

                      // Courier Logo
                      if (courier['courier_image'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.network(
                            courier['courier_image'],
                            height: 48.h,
                            width: 48.w,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 48.h,
                                  width: 48.w,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    Icons.local_shipping,
                                    color: Colors.grey,
                                  ),
                                ),
                          ),
                        ),
                      SizedBox(width: 12.w),

                      // Courier Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              courier['courier_name'] ?? 'Unknown Courier',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ...List.generate(
                                  5,
                                  (i) => Icon(
                                    i < ratings.floor()
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 13.sp,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Flexible(
                                  child: Text(
                                    '$ratings ($votes)',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
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
                          if (hasDiscount)
                            Text(
                              '₦${courier['rate_card_amount']?.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            '₦${courier['total']?.toStringAsFixed(2) ?? '0.00'}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              color: const Color(0xFF3F4492),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),
                  Divider(height: 1, color: Colors.grey[200]),
                  SizedBox(height: 12.h),

                  // Details Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          Icons.access_time,
                          'Pickup',
                          courier['pickup_eta'] ?? 'N/A',
                        ),
                      ),
                      Container(
                        height: 30.h,
                        width: 1,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          Icons.local_shipping,
                          'Delivery',
                          courier['delivery_eta'] ?? 'N/A',
                        ),
                      ),
                      Container(
                        height: 30.h,
                        width: 1,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          Icons.track_changes,
                          'Tracking',
                          tracking != null ? tracking['label'] ?? 'N/A' : 'N/A',
                          color: _getTrackingColor(tracking),
                        ),
                      ),
                    ],
                  ),

                  // Tracking Bars
                  if (tracking != null && tracking['bars'] != null) ...[
                    SizedBox(height: 12.h),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Expanded(
                          child: Container(
                            height: 4.h,
                            margin: EdgeInsets.symmetric(horizontal: 2.w),
                            decoration: BoxDecoration(
                              color: i < tracking['bars']
                                  ? _getTrackingColor(tracking)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18.sp, color: color ?? Colors.grey[600]),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Color _getTrackingColor(Map<String, dynamic>? tracking) {
    if (tracking == null) return Colors.grey;
    final label = tracking['label']?.toString().toLowerCase() ?? '';
    if (label.contains('excellent')) return Colors.green;
    if (label.contains('good')) return Colors.blue;
    if (label.contains('average')) return Colors.orange;
    return Colors.grey;
  }
}
