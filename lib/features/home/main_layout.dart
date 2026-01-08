import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:starhills/features/home/controllers/profile_controller.dart';
import 'package:starhills/model/courier_model.dart';
import 'home_screen.dart';
import 'drop_off_screen.dart';
import 'package:starhills/features/home/profile_screen.dart';

import 'package:starhills/features/home/shipment_history_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final ProfileController profileController = Get.put(ProfileController());

  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    DropOffScreen(
      selectedRider: CourierModel(),
    ), // Pass empty model, will be selected later
    const ShipmentHistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF3F4492),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.boxOpen),
            label: 'Parcels',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.gps_fixed), label: 'Track'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
