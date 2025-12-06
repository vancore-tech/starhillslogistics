import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:starhills/features/home/controllers/roders_controller.dart';
import 'package:starhills/features/home/drop_off_screen.dart';
import 'package:starhills/model/courier_model.dart';

class AvailableRidersScreen extends StatefulWidget {
  const AvailableRidersScreen({super.key});

  @override
  State<AvailableRidersScreen> createState() => _AvailableRidersScreenState();
}

class _AvailableRidersScreenState extends State<AvailableRidersScreen> {
  final RidersController ridersController = Get.put(RidersController());


  int? _selectedRiderIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: Text(
          'Available Riders',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        return ridersController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  SizedBox(height: 10.h),
                  // Riders List
                  Expanded(
                    child: Obx(() {
                      return ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        itemCount: ridersController.riders.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 15.h),
                        itemBuilder: (context, index) {
                          final rider = ridersController.riders[index];
                          return _buildRiderCard(rider, index);
                        },
                      );
                    }),
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
                        onPressed: _selectedRiderIndex != null
                            ? () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  final selectedRider = ridersController
                                      .riders[_selectedRiderIndex!];
                                  return DropOffScreen(selectedRider: selectedRider);
                                }));
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F4492),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Confirm Rider',
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
              );
      }),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF6),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF3F4492),
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 5.w),
          Icon(
            Icons.keyboard_arrow_down,
            color: const Color(0xFF3F4492),
            size: 16.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildRiderCard(CourierModel rider, int index) {
    final isSelected = _selectedRiderIndex == index;

    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: isSelected
            ? Border.all(color: const Color(0xFF3F4492), width: 2)
            : null,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 25.r,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: rider.pinImage != null
                    ? NetworkImage(rider.pinImage!)
                    : null,
                child: rider.pinImage == null
                    ? Icon(Icons.person, color: Colors.grey.shade600)
                    : null,
              ),
              SizedBox(width: 15.w),
              // Name and Rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: rider.name,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: ' - ${rider.status}',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5.h),
                    // Row(
                    //   children: [
                    //     Icon(Icons.star, color: Colors.amber, size: 16.sp),
                    //     SizedBox(width: 5.w),
                    //     Text(
                    //       rider.rating.toString(),
                    //       style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
              // Select Button
              InkWell(
                onTap: () {
                  setState(() {
                    _selectedRiderIndex = index;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EAF6),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Select',
                    style: TextStyle(
                      color: const Color(0xFF3F4492),
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Divider(color: Colors.grey.shade200),
          SizedBox(height: 10.h),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(
          //       rider['time'],
          //       style: TextStyle(color: Colors.grey, fontSize: 14.sp),
          //     ),
          //     Text(
          //       '₦ ${rider['price']}', // Assuming Naira symbol
          //       style: TextStyle(
          //         color: Colors.black,
          //         fontSize: 16.sp,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
