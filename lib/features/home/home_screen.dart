import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:starhills/features/auth/controllers/auth_controller.dart';
import 'package:starhills/features/auth/login_screen.dart';
import 'available_riders_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());

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
                  ),
                  _buildActionCard(
                    title: 'Track Delivery',
                    icon: FontAwesomeIcons.mapLocationDot,
                    color: const Color(0xFFE8EAF6),
                    imagePath: 'assets/images/map.png',
                    isImage: true,
                  ),
                  _buildActionCard(
                    title: 'Wallet',
                    icon: FontAwesomeIcons.wallet,
                    color: const Color(0xFFE8EAF6),
                    imagePath: 'assets/images/wallet.png', // Placeholder
                    isImage:
                        true, // Assuming third.png is wallet related or similar based on onboarding
                  ),
                  _buildActionCard(
                    title: 'Book a Rider',
                    icon: FontAwesomeIcons.motorcycle,
                    color: const Color(0xFFE8EAF6),
                    imagePath: 'assets/images/route.png', // Placeholder
                    isImage: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AvailableRidersScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 30.h),
              Container(
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Active Delivery Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Active Delivery',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AvailableRidersScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'See All',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF3F4492),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      children: [
                        Container(
                          width: 60.w,
                          height: 60.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Center(
                            child: Icon(
                              FontAwesomeIcons.box,
                              color: const Color(0xFF3F4492),
                              size: 30.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 15.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Package #1234567889',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                'In Transit',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5.r),
                      child: LinearProgressIndicator(
                        value: 0.7,
                        backgroundColor: const Color(0xFFE8EAF6),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF3F4492),
                        ),
                        minHeight: 8.h,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
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
