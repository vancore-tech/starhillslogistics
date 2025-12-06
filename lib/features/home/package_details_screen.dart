import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:starhills/const/api_config.dart';
import 'package:starhills/const/const.dart';
import 'package:starhills/model/category_model.dart';
import 'package:starhills/model/rate_courier_model.dart';
import 'package:starhills/utils/storage_helper.dart' as StorageHelper;
import 'drop_off_controller.dart';
import 'rate_couriers_screen.dart';

class PackageDetailsScreen extends StatefulWidget {
  const PackageDetailsScreen({super.key});

  @override
  State<PackageDetailsScreen> createState() => _PackageDetailsScreenState();
}

class _PackageDetailsScreenState extends State<PackageDetailsScreen> {
  final controller = Get.find<DropOffController>();

  final _formKey = GlobalKey<FormState>();

  // Package Items
  final _itemNameController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _unitWeightController = TextEditingController();
  final _unitAmountController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  // Package Dimensions
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  // Other fields
  final _pickupDateController = TextEditingController();
  final _deliveryInstructionsController = TextEditingController();

  String _serviceType = 'pickup';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set default pickup date to today
    _pickupDateController.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _unitWeightController.dispose();
    _unitAmountController.dispose();
    _quantityController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _pickupDateController.dispose();
    _deliveryInstructionsController.dispose();
    super.dispose();
  }

  Future<void> _createRate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (controller.selectedCategoryId.value == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = StorageHelper.getToken();

      final requestBody = {
        "sender_address_code": 802132098,
        "reciever_address_code": 802132098,
        "pickup_date": _pickupDateController.text,
        "category_id": controller.selectedCategoryId.value,
        "package_items": [
          {
            "name": _itemNameController.text,
            "description": _itemDescriptionController.text,
            "unit_weight": double.tryParse(_unitWeightController.text) ?? 0.0,
            "unit_amount": int.tryParse(_unitAmountController.text) ?? 0,
            "quantity": int.tryParse(_quantityController.text) ?? 1,
          },
        ],
        "package_dimension": {
          "length": int.tryParse(_lengthController.text) ?? 0,
          "width": int.tryParse(_widthController.text) ?? 0,
          "height": int.tryParse(_heightController.text) ?? 0,
        },
        "service_type": _serviceType,
        "delivery_instructions": _deliveryInstructionsController.text,
      };

      debugPrint('Creating rate with data:');
      debugPrint(jsonEncode(requestBody));

      var response = await http.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.createRate),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('Create rate response status: ${response.statusCode}');

      // Format JSON response for better readability in console
      try {
        final jsonResponse = jsonDecode(response.body);
        const encoder = JsonEncoder.withIndent('  ');
        final formattedResponse = encoder.convert(jsonResponse);
        debugPrint(
          'Create rate response body (formatted):\n$formattedResponse',
        );
      } catch (e) {
        debugPrint('Create rate response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse response
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true) {
          // Extract couriers and request token
          final data = jsonResponse['data']['data'];
          final requestToken = data['request_token'] as String;
          final couriersJson = data['couriers'] as List;

          // Convert to RateCourierModel list
          final couriers = couriersJson
              .map((json) => RateCourierModel.fromJson(json))
              .toList();

          // Navigate to rate couriers screen with package details
          Get.to(
            () => RateCouriersScreen(
              couriers: couriers,
              requestToken: requestToken,
              packageData: {
                'sender_address_code': 802132098,
                'reciever_address_code': 802132098,
                'pickup_date': _pickupDateController.text,
                'category_id': controller.selectedCategoryId.value,
                'package_items': [
                  {
                    'name': _itemNameController.text,
                    'description': _itemDescriptionController.text,
                    'unit_weight':
                        double.tryParse(_unitWeightController.text) ?? 0.0,
                    'unit_amount':
                        int.tryParse(_unitAmountController.text) ?? 0,
                    'quantity': int.tryParse(_quantityController.text) ?? 1,
                  },
                ],
                'package_dimension': {
                  'length': int.tryParse(_lengthController.text) ?? 0,
                  'width': int.tryParse(_widthController.text) ?? 0,
                  'height': int.tryParse(_heightController.text) ?? 0,
                },
                'service_type': _serviceType,
                'delivery_instructions': _deliveryInstructionsController.text,
              },
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(jsonResponse['message'] ?? 'Failed to fetch rates'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create rate: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error creating rate: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Package Details",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected Category Display
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: primaryColor, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.category, color: primaryColor, size: 24.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Obx(() {
                        final selectedCategory = controller.categories
                            .firstWhere(
                              (cat) =>
                                  cat.categoryId ==
                                  controller.selectedCategoryId.value,
                              orElse: () => CategoryModel(),
                            );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Category',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              selectedCategory.category ?? 'None',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Package Item Section
              _buildSectionTitle('Package Item'),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _itemNameController,
                label: 'Item Name',
                hint: 'e.g., Laptop',
                validator: (val) => val?.isEmpty ?? true ? 'Required' : null,
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _itemDescriptionController,
                label: 'Description',
                hint: 'e.g., Gaming Laptop',
                validator: (val) => val?.isEmpty ?? true ? 'Required' : null,
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _unitWeightController,
                      label: 'Weight (kg)',
                      hint: '2.5',
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          val?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildTextField(
                      controller: _quantityController,
                      label: 'Quantity',
                      hint: '1',
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          val?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _unitAmountController,
                label: 'Item Value (₦)',
                hint: '500000',
                keyboardType: TextInputType.number,
                validator: (val) => val?.isEmpty ?? true ? 'Required' : null,
              ),
              SizedBox(height: 24.h),

              // Package Dimensions Section
              _buildSectionTitle('Package Dimensions (cm)'),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _lengthController,
                      label: 'Length',
                      hint: '40',
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          val?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildTextField(
                      controller: _widthController,
                      label: 'Width',
                      hint: '30',
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          val?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildTextField(
                      controller: _heightController,
                      label: 'Height',
                      hint: '10',
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          val?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Service Type Section
              _buildSectionTitle('Service Type'),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(child: _buildRadioOption('Pickup', 'pickup')),
                  SizedBox(width: 12.w),
                  Expanded(child: _buildRadioOption('Drop-off', 'dropoff')),
                ],
              ),
              SizedBox(height: 24.h),

              // Pickup Date
              _buildSectionTitle('Pickup Date'),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _pickupDateController,
                label: 'Date',
                hint: 'YYYY-MM-DD',
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    _pickupDateController.text = date.toString().split(' ')[0];
                  }
                },
                validator: (val) => val?.isEmpty ?? true ? 'Required' : null,
              ),
              SizedBox(height: 24.h),

              // Delivery Instructions
              _buildSectionTitle('Delivery Instructions (Optional)'),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _deliveryInstructionsController,
                label: 'Instructions',
                hint: 'e.g., Leave at reception',
                maxLines: 3,
              ),
              SizedBox(height: 24.h),

              // Calculate Rate Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createRate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Calculate Rate",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }

  Widget _buildRadioOption(String label, String value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _serviceType = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: _serviceType == value
              ? primaryColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: _serviceType == value ? primaryColor : Colors.grey[300]!,
            width: _serviceType == value ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio<String>(
              value: value,
              groupValue: _serviceType,
              onChanged: (val) {
                setState(() {
                  _serviceType = val!;
                });
              },
              activeColor: primaryColor,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: _serviceType == value
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: _serviceType == value ? primaryColor : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
