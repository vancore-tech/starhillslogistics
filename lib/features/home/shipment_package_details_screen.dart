import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'shipment_courier_selection_screen.dart';
import 'dart:convert';
import 'shipment_controller.dart';

class ShipmentPackageDetailsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> dimensions;
  final int senderAddressCode;
  final int receiverAddressCode;
  const ShipmentPackageDetailsScreen({
    super.key,
    required this.categories,
    required this.dimensions,
    required this.senderAddressCode,
    required this.receiverAddressCode,
  });

  @override
  State<ShipmentPackageDetailsScreen> createState() =>
      _ShipmentPackageDetailsScreenState();
}

class _ShipmentPackageDetailsScreenState
    extends State<ShipmentPackageDetailsScreen> {
  final ShipmentController shipmentController = Get.put(ShipmentController());
  bool isLoadingNext = false;
  final _formKey = GlobalKey<FormState>();
  int? selectedCategoryId;
  int? selectedDimensionIndex;
  final TextEditingController weightController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Items
  List<Map<String, dynamic>> items = [];
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemQtyController = TextEditingController();
  final TextEditingController itemPriceController = TextEditingController();

  // COD & Insurance
  bool enableCOD = false;
  final TextEditingController codAmountController = TextEditingController();
  bool enableInsurance = false;
  final TextEditingController insuranceValueController =
      TextEditingController();

  // Dimension details
  final TextEditingController heightController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();

  @override
  void dispose() {
    weightController.dispose();
    descriptionController.dispose();
    itemNameController.dispose();
    itemQtyController.dispose();
    itemPriceController.dispose();
    codAmountController.dispose();
    insuranceValueController.dispose();
    heightController.dispose();
    widthController.dispose();
    lengthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Create New Shipment',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
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
              Text(
                'Step 2 of 3',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 18.h),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 1,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2,
                            color: Colors.orange,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Package Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      // Category Dropdown
                      DropdownButtonFormField<int>(
                        value: selectedCategoryId,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                        ),
                        isExpanded: true,
                        items: widget.categories
                            .map(
                              (cat) => DropdownMenuItem<int>(
                                value: cat['category_id'],
                                child: Text(
                                  cat['category'],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedCategoryId = val),
                        validator: (val) => val == null ? 'Required' : null,
                      ),
                      SizedBox(height: 12.h),
                      // Dimension Selector
                      Text(
                        'Dimension',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(widget.dimensions.length, (
                            i,
                          ) {
                            final dim = widget.dimensions[i];
                            final selected = selectedDimensionIndex == i;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedDimensionIndex = i;
                                  heightController.text = dim['height']
                                      .toString();
                                  widthController.text = dim['width']
                                      .toString();
                                  lengthController.text = dim['length']
                                      .toString();
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 10.w),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(0xFF3F4492)
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: selected
                                        ? const Color(0xFF3F4492)
                                        : Colors.grey[300]!,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    if (dim['description_image_url'] != null)
                                      Image.network(
                                        dim['description_image_url'],
                                        height: 28.h,
                                        width: 28.w,
                                        fit: BoxFit.contain,
                                      ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      dim['name'],
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: selected
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // Show selected dimension details
                      if (selectedDimensionIndex != null) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: heightController,
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'Height',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 12.h,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: TextFormField(
                                controller: widthController,
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'Width',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 12.h,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: TextFormField(
                                controller: lengthController,
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'Length',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 12.h,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                      ],
                      // Weight
                      TextFormField(
                        controller: weightController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Weight (kg)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 12.h),
                      // Description
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 22.h),
              // Items (Optional)
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 1,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.list_alt, color: Colors.teal, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'Items (Optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      ...items.map(
                        (item) => Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item['name']}  Qty: ${item['qty']}  ₦${item['price']}',
                                  style: TextStyle(fontSize: 13.sp),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  size: 18.sp,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    setState(() => items.remove(item)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Item entry row (guaranteed no overflow)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 120.w,
                              child: TextFormField(
                                controller: itemNameController,
                                decoration: InputDecoration(
                                  labelText: 'Item Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 12.h,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            SizedBox(
                              width: 60.w,
                              child: TextFormField(
                                controller: itemQtyController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Qty',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 12.h,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            SizedBox(
                              width: 80.w,
                              child: TextFormField(
                                controller: itemPriceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: '₦ Price',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 12.h,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            IconButton(
                              icon: Icon(
                                Icons.add_circle,
                                color: Colors.green,
                                size: 24.sp,
                              ),
                              onPressed: () {
                                if (itemNameController.text.isNotEmpty &&
                                    itemQtyController.text.isNotEmpty &&
                                    itemPriceController.text.isNotEmpty) {
                                  setState(() {
                                    items.add({
                                      'name': itemNameController.text,
                                      'qty': itemQtyController.text,
                                      'price': itemPriceController.text,
                                    });
                                    itemNameController.clear();
                                    itemQtyController.clear();
                                    itemPriceController.clear();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 22.h),
              // COD
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 1,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            color: Colors.purple,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Cash on Delivery',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Checkbox(
                            value: enableCOD,
                            onChanged: (val) =>
                                setState(() => enableCOD = val ?? false),
                          ),
                          Text('Enable COD', style: TextStyle(fontSize: 13.sp)),
                          SizedBox(width: 12.w),
                          if (enableCOD)
                            Expanded(
                              child: TextFormField(
                                controller: codAmountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Amount',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 12.h,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 22.h),
              // Insurance
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 1,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.verified_user,
                            color: Colors.blueGrey,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Insurance',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Checkbox(
                            value: enableInsurance,
                            onChanged: (val) =>
                                setState(() => enableInsurance = val ?? false),
                          ),
                          Text(
                            'Add Insurance',
                            style: TextStyle(fontSize: 13.sp),
                          ),
                          SizedBox(width: 12.w),
                          if (enableInsurance)
                            Expanded(
                              child: TextFormField(
                                controller: insuranceValueController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Value',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 12.h,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              // Button row (fix overflow)
              Row(
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
                    child: ElevatedButton(
                      onPressed: isLoadingNext
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate() &&
                                  selectedCategoryId != null &&
                                  selectedDimensionIndex != null) {
                                setState(() => isLoadingNext = true);
                                // Build rateRequestBody from form fields
                                final selectedDim =
                                    widget.dimensions[selectedDimensionIndex!];
                                final rateRequestBody = {
                                  'sender_address_code':
                                      widget.senderAddressCode,
                                  'reciever_address_code':
                                      widget.receiverAddressCode,
                                  'pickup_date': DateTime.now()
                                      .toIso8601String()
                                      .split('T')[0],
                                  'category_id': selectedCategoryId,
                                  'service_type':
                                      'pickup', // TODO: Replace with actual service type if needed
                                  'delivery_instructions': descriptionController
                                      .text, // Or another field for instructions
                                  'package_items': items.isNotEmpty
                                      ? items
                                            .map(
                                              (item) => {
                                                'name': item['name'],
                                                'description':
                                                    descriptionController.text,
                                                'unit_weight':
                                                    weightController.text,
                                                'unit_amount': item['price'],
                                                'quantity': item['qty'],
                                              },
                                            )
                                            .toList()
                                      : [
                                          {
                                            'name':
                                                itemNameController
                                                    .text
                                                    .isNotEmpty
                                                ? itemNameController.text
                                                : 'Test Package',
                                            'description':
                                                descriptionController
                                                    .text
                                                    .isNotEmpty
                                                ? descriptionController.text
                                                : 'Test shipment',
                                            'unit_weight':
                                                weightController.text.isNotEmpty
                                                ? weightController.text
                                                : '0.002',
                                            'unit_amount':
                                                itemPriceController
                                                    .text
                                                    .isNotEmpty
                                                ? itemPriceController.text
                                                : '25000.00',
                                            'quantity':
                                                itemQtyController
                                                    .text
                                                    .isNotEmpty
                                                ? itemQtyController.text
                                                : '2',
                                          },
                                        ],
                                  'package_dimension': {
                                    'length':
                                        int.tryParse(lengthController.text) ??
                                        selectedDim['length'],
                                    'width':
                                        int.tryParse(widthController.text) ??
                                        selectedDim['width'],
                                    'height':
                                        int.tryParse(heightController.text) ??
                                        selectedDim['height'],
                                  },
                                };
                                // Call fetchRates in the controller
                                debugPrint(
                                  '[ShipmentPackageDetailsScreen] rateRequestBody:',
                                );
                                debugPrint(rateRequestBody.toString());
                                debugPrint(
                                  '[ShipmentPackageDetailsScreen] rateRequestBody JSON:',
                                );
                                debugPrint(
                                  const JsonEncoder.withIndent(
                                    '  ',
                                  ).convert(rateRequestBody),
                                );
                                await shipmentController.fetchRates(
                                  rateRequestBody,
                                );
                                debugPrint(
                                  '[ShipmentPackageDetailsScreen] couriers after fetchRates:',
                                );
                                debugPrint(
                                  shipmentController.couriers.toString(),
                                );
                                setState(() => isLoadingNext = false);
                                // Only navigate if couriers are found
                                if (shipmentController.couriers.isNotEmpty) {
                                  Get.to(
                                    () => ShipmentCourierSelectionScreen(
                                      rateRequestBody: rateRequestBody,
                                    ),
                                  );
                                } else {
                                  Get.snackbar(
                                    'No Couriers',
                                    'No couriers found for the selected package details.',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              }
                            },
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
                      child: isLoadingNext
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Next: Choose Courier →',
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
