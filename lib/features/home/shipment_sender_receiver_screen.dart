import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'controllers/profile_controller.dart';
import 'shipment_package_details_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../const/api_config.dart';
import 'package:starhills/utils/storage_helper.dart' as StorageHelper;

class ShipmentSenderReceiverScreen extends StatefulWidget {
  final String senderAddress;
  final String receiverAddress;
  final int senderAddressCode;
  final int receiverAddressCode;
  const ShipmentSenderReceiverScreen({
    super.key,
    required this.senderAddress,
    required this.receiverAddress,
    required this.senderAddressCode,
    required this.receiverAddressCode,
  });

  @override
  State<ShipmentSenderReceiverScreen> createState() => _ShipmentSenderReceiverScreenState();
}

class _ShipmentSenderReceiverScreenState extends State<ShipmentSenderReceiverScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileController profileController = Get.find<ProfileController>();

  // Receiver fields
  final TextEditingController receiverNameController = TextEditingController();
  final TextEditingController receiverPhoneController = TextEditingController();
  final TextEditingController receiverEmailController = TextEditingController();
  final TextEditingController receiverAddressController = TextEditingController();
  final TextEditingController receiverCityController = TextEditingController();
  final TextEditingController receiverStateController = TextEditingController();
  final TextEditingController receiverCountryController = TextEditingController(text: 'Nigeria');

  @override
  void initState() {
    super.initState();
    receiverAddressController.text = widget.receiverAddress;
  }

  @override
  void dispose() {
    receiverNameController.dispose();
    receiverPhoneController.dispose();
    receiverEmailController.dispose();
    receiverAddressController.dispose();
    receiverCityController.dispose();
    receiverStateController.dispose();
    receiverCountryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = profileController.profile.value;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Create New Shipment', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Step 1 of 3', style: TextStyle(fontSize: 13.sp, color: Colors.grey[600], fontWeight: FontWeight.w500)),
              SizedBox(height: 18.h),
              // SENDER INFO
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 1,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.send, color: Colors.blue, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text('Sender Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp)),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      _buildTextField('Name', initialValue: user.fullName ?? '', enabled: false),
                      _buildTextField('Phone', initialValue: user.phone ?? '', enabled: false),
                      _buildTextField('Email', initialValue: user.email ?? '', enabled: false),
                      _buildTextField('Address', initialValue: widget.senderAddress, enabled: false),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('City', initialValue: '', enabled: false)),
                          SizedBox(width: 10.w),
                          Expanded(child: _buildTextField('State', initialValue: '', enabled: false)),
                        ],
                      ),
                      _buildTextField('Country', initialValue: 'Nigeria', enabled: false),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 22.h),
              // RECEIVER INFO
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 1,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.inbox, color: Colors.green, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text('Receiver Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp)),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      _buildTextField('Name', controller: receiverNameController, validator: _requiredValidator),
                      _buildTextField('Phone', controller: receiverPhoneController, validator: _requiredValidator),
                      _buildTextField('Email', controller: receiverEmailController),
                      _buildTextField('Address', controller: receiverAddressController, validator: _requiredValidator),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('City', controller: receiverCityController, validator: _requiredValidator)),
                          SizedBox(width: 10.w),
                          Expanded(child: _buildTextField('State', controller: receiverStateController, validator: _requiredValidator)),
                        ],
                      ),
                      _buildTextField('Country', controller: receiverCountryController, validator: _requiredValidator),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                      side: const BorderSide(color: Color(0xFF3F4492)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text('Back', style: TextStyle(fontSize: 15.sp, color: const Color(0xFF3F4492))),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final token = StorageHelper.getToken();
                        // Fetch categories and dimensions in parallel with Bearer token
                        final responses = await Future.wait([
                          http.get(
                            Uri.parse('https://starhills-logistcis-be-avbmfugsewgbcvg7.canadacentral-01.azurewebsites.net/api/v1/packages/categories'),
                            headers: {
                              'Content-Type': 'application/json',
                              'Authorization': 'Bearer $token',
                            },
                          ),
                          http.get(
                            Uri.parse('https://starhills-logistcis-be-avbmfugsewgbcvg7.canadacentral-01.azurewebsites.net/api/v1/packages/dimensions'),
                            headers: {
                              'Content-Type': 'application/json',
                              'Authorization': 'Bearer $token',
                            },
                          ),
                        ]);
                        final categoriesJson = jsonDecode(responses[0].body);
                        final dimensionsJson = jsonDecode(responses[1].body);
                        final categories = (categoriesJson['categories'] ?? []) as List;
                        final dimensions = (dimensionsJson['dimensions'] ?? []) as List;
                        print('DEBUG: Categories passed to next screen:');
                        print(categories);
                        print('DEBUG: Dimensions passed to next screen:');
                        print(dimensions);
                        Get.to(() => ShipmentPackageDetailsScreen(
                              categories: List<Map<String, dynamic>>.from(categories),
                              dimensions: List<Map<String, dynamic>>.from(dimensions),
                              senderAddressCode: widget.senderAddressCode,
                              receiverAddressCode: widget.receiverAddressCode,
                            ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F4492),
                      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text('Next: Package →', style: TextStyle(fontSize: 15.sp, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {String? initialValue, TextEditingController? controller, bool enabled = true, String? Function(String?)? validator}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        enabled: enabled,
        validator: validator,
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }
}
