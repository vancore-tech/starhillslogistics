import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import 'package:starhills/utils/storage_helper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  final List<Map<String, String>> _onboardingData = [
    {
      'image': 'assets/images/first.png',
      'text': 'Book deliveries in\nseconds.',
    },
    {
      'image': 'assets/images/second.png',
      'text': 'Track your package\nin real-time.',
    },
    {
      'image': 'assets/images/third.png',
      'text': 'Pay Safely with\nwallet or card.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 50.h),
            // PageView Section
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) {},
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      // Image Container with Dashed Border (Simulated with Image for now as per asset usage)
                      // The user provided an image that looks like it has the dashed border built-in or is part of the design.
                      // However, the user said "use the first-third image".
                      // I will assume the images provided are the illustrations inside the oval.
                      // I will wrap them in a dashed border container.
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Container(
                          width: double.infinity,
                          height: 300.h,
                          padding: EdgeInsets.all(20.w),
                          child: Center(
                            child: Image.asset(
                              _onboardingData[index]['image']!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        _onboardingData[index]['text']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Indicator
            SmoothPageIndicator(
              controller: _controller,
              count: _onboardingData.length,
              effect: ExpandingDotsEffect(
                activeDotColor: const Color(0xFF3F4492),
                dotColor: Colors.grey.shade300,
                dotHeight: 8.h,
                dotWidth: 8.w,
                spacing: 8.w,
              ),
            ),
            SizedBox(height: 50.h),
            // Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () {
                        saveOnboardingStatus(true);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F4492),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () {
                        saveOnboardingStatus(true);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFE8EAF6,
                        ), // Light purple/blue background
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: const Color(0xFF3F4492),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Terms of Service',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
