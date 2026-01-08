import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:starhills/features/auth/controllers/auth_controller.dart';
import 'package:starhills/features/auth/login_screen.dart';
import 'package:starhills/features/home/package_details_screen.dart';
import 'package:starhills/features/home/controllers/shipment_statistics_controller.dart';
import 'package:starhills/features/home/controllers/wallet_controller.dart';
import 'package:starhills/features/home/shipment_history_screen.dart';
import 'package:starhills/features/home/shipment_controller.dart';
import 'package:starhills/features/home/shipment_details_screen.dart';
import 'package:starhills/features/home/wallet_screen.dart';
import 'package:starhills/model/courier_model.dart';
import 'drop_off_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());
    final ShipmentStatisticsController statisticsController = Get.put(
      ShipmentStatisticsController(),
    );
    final WalletController walletController = Get.put(WalletController());
    final ShipmentController shipmentController = Get.put(ShipmentController());

    // Fetch shipments if empty (optional, but good for caching)
    if (shipmentController.userShipments.isEmpty) {
      shipmentController.fetchUserShipments();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 40.h,
                    fit: BoxFit.contain,
                  ),
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              authController.clearToken();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            child: Icon(
                              Icons.notifications_outlined,
                              size: 24.sp,
                              color: Colors.black,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8.w,
                              height: 8.h,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Search Bar
              Container(
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter Tracking Number',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15.h),
                  ),
                ),
              ),
              SizedBox(height: 30.h),

              // Action Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15.w,
                mainAxisSpacing: 15.h,
                childAspectRatio: 1.1,
                children: [
                  _buildActionCard(
                    title: 'Send Package',
                    icon: FontAwesomeIcons.boxOpen, // Placeholder icon
                    color: const Color(0xFFE8EAF6),
                    imagePath:
                        'assets/images/box.png', // Using existing assets as placeholders if needed, or icons
                    isImage: true,
                    onTap: () {
                      Get.to(
                        () => DropOffScreen(selectedRider: CourierModel()),
                      );
                    },
                  ),
                  _buildActionCard(
                    title: 'Track Delivery',
                    icon: FontAwesomeIcons.mapLocationDot,
                    color: const Color(0xFFE8EAF6),
                    imagePath: 'assets/images/map.png',
                    isImage: true,
                    onTap: () {
                      Get.to(() => const ShipmentHistoryScreen());
                    },
                  ),
                  _buildActionCard(
                    title: 'Wallet',
                    icon: FontAwesomeIcons.wallet,
                    color: const Color(0xFFE8EAF6),
                    imagePath: 'assets/images/wallet.png', // Placeholder
                    isImage:
                        true, // Assuming third.png is wallet related or similar based on onboarding
                    onTap: () {
                      Get.to(() => const WalletScreen());
                    },
                  ),
                  _buildActionCard(
                    title: 'Book a Rider',
                    icon: FontAwesomeIcons.motorcycle,
                    color: const Color(0xFFE8EAF6),
                    imagePath: 'assets/images/route.png', // Placeholder
                    isImage: true,
                    onTap: () {
                      Get.to(
                        () => DropOffScreen(selectedRider: CourierModel()),
                      );
                    },
                  ),
                ],
              ),
              // SizedBox(height: 30.h),
              // Container(
              //   padding: EdgeInsets.all(15.w),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(15.r),
              //     boxShadow: const [
              //       BoxShadow(
              //         color: Colors.black12,
              //         blurRadius: 5,
              //         offset: Offset(0, 2),
              //       ),
              //     ],
              //   ),
              //   child: Column(
              //     children: [
              //       // Active Delivery Section
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Text(
              //             'Active Delivery',
              //             style: TextStyle(
              //               fontSize: 18.sp,
              //               fontWeight: FontWeight.bold,
              //               color: Colors.black,
              //             ),
              //           ),
              //           GestureDetector(
              //             onTap: () {
              //               Navigator.push(
              //                 context,
              //                 MaterialPageRoute(
              //                   builder: (context) =>
              //                       const AvailableRidersScreen(),
              //                 ),
              //               );
              //             },
              //             child: Text(
              //               'See All',
              //               style: TextStyle(
              //                 fontSize: 14.sp,
              //                 color: const Color(0xFF3F4492),
              //                 fontWeight: FontWeight.bold,
              //                 decoration: TextDecoration.underline,
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //       SizedBox(height: 15.h),
              //       Row(
              //         children: [
              //           Container(
              //             width: 60.w,
              //             height: 60.h,
              //             decoration: BoxDecoration(
              //               color: Colors.grey.shade100,
              //               borderRadius: BorderRadius.circular(10.r),
              //             ),
              //             child: Center(
              //               child: Icon(
              //                 FontAwesomeIcons.box,
              //                 color: const Color(0xFF3F4492),
              //                 size: 30.sp,
              //               ),
              //             ),
              //           ),
              //           SizedBox(width: 15.w),
              //           Expanded(
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Text(
              //                   'Package #1234567889',
              //                   style: TextStyle(
              //                     fontSize: 16.sp,
              //                     fontWeight: FontWeight.bold,
              //                     color: Colors.black,
              //                   ),
              //                 ),
              //                 SizedBox(height: 5.h),
              //                 Text(
              //                   'In Transit',
              //                   style: TextStyle(
              //                     fontSize: 14.sp,
              //                     color: Colors.grey,
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ],
              //       ),
              //       SizedBox(height: 15.h),
              //       // Progress Bar
              //       ClipRRect(
              //         borderRadius: BorderRadius.circular(5.r),
              //         child: LinearProgressIndicator(
              //           value: 0.7,
              //           backgroundColor: const Color(0xFFE8EAF6),
              //           valueColor: const AlwaysStoppedAnimation<Color>(
              //             Color(0xFF3F4492),
              //           ),
              //           minHeight: 8.h,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              SizedBox(height: 30.h),

              // Shipment Statistics
              Text(
                'SHIPMENT STATISTICS',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 10.h),
              Obx(() {
                final stats = statisticsController.statistics.value;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard(
                      stats.total.toString(),
                      'Total',
                      Colors.blue,
                    ),
                    _buildStatCard(
                      stats.delivered.toString(),
                      'Delivered',
                      Colors.green,
                    ),
                    _buildStatCard(
                      stats.inTransit.toString(),
                      'Transit',
                      Colors.orange,
                    ),
                    _buildStatCard(
                      stats.cancelled.toString(),
                      'Cancelled',
                      Colors.red,
                    ),
                  ],
                );
              }),
              SizedBox(height: 30.h),

              // Wallet Balance
              Obx(() {
                final balance = walletController.balance.value;
                final currency = walletController.currency.value;
                return Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F4492),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WALLET BALANCE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            '${currency == 'NGN' ? '₦' : ''}${balance.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF3F4492),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        child: const Text('+ Add Funds'),
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(height: 30.h),

              // Recent Shipments
              Text(
                'RECENT SHIPMENTS',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 10.h),
              Obx(() {
                if (shipmentController.isLoadingShipments.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3F4492)),
                  );
                }

                if (shipmentController.userShipments.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: Center(
                      child: Text(
                        'No recent shipments found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                }

                final recentShipments = shipmentController.userShipments
                    .take(3)
                    .toList();

                return Container(
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
                      for (int i = 0; i < recentShipments.length; i++) ...[
                        GestureDetector(
                          onTap: () async {
                            // We could navigate passing the object directly, but maybe fetch full details first?
                            // ShipmentHistoryScreen fetches details. Let's do the same.
                            await shipmentController.fetchShipmentDetails(
                              recentShipments[i].id,
                            );
                            Get.to(
                              () => ShipmentDetailsScreen(
                                shipment: recentShipments[i],
                              ),
                            );
                          },
                          child: _buildShipmentRow(
                            recentShipments[i].trackingNumber,
                            recentShipments[i].senderCity ??
                                recentShipments[i]
                                    .senderAddress, // Use city or fallback
                            recentShipments[i].receiverCity ??
                                recentShipments[i].receiverAddress,
                            recentShipments[i].status,
                            _getStatusColor(recentShipments[i].status),
                          ),
                        ),
                        if (i < recentShipments.length - 1)
                          const Divider(height: 1),
                      ],
                    ],
                  ),
                );
              }),
              SizedBox(height: 30.h),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Ensure shipmentController is reset or ready for new shipment
                        // Actually PackageDetailsScreen handles flow.
                        Get.to(() => const PackageDetailsScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F4492),
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'Create Shipment',
                        style: TextStyle(fontSize: 16.sp, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.to(() => const ShipmentHistoryScreen());
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        side: const BorderSide(color: Color(0xFF3F4492)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'View All Shipments',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: const Color(0xFF3F4492),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String count, String label, Color color) {
    return Container(
      width: 80.w,
      padding: EdgeInsets.symmetric(vertical: 15.h),
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
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentRow(
    String id,
    String from,
    String to,
    String status,
    Color statusColor,
  ) {
    return Padding(
      padding: EdgeInsets.all(15.r),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  id,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    Text(
                      from,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      to,
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'delivered':
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'transit':
      case 'in_transit':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildActionCard({
    required String title,
    IconData? icon,
    required Color color,
    String? imagePath,
    bool isImage = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isImage && imagePath != null)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Image.asset(imagePath, fit: BoxFit.contain),
                ),
              )
            else
              Icon(icon, size: 40.sp, color: const Color(0xFF3F4492)),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
