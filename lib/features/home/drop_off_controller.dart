import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:starhills/const/api_config.dart';
import 'package:starhills/model/category_model.dart';
import 'package:starhills/utils/storage_helper.dart' as StorageHelper;

class DropOffController extends GetxController {
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropoffController = TextEditingController();

  final RxString selectedPickupLocation = ''.obs;
  final RxString selectedDropoffLocation = ''.obs;

  // Location coordinates
  Rx<LatLng?> pickupLatLng = Rx<LatLng?>(null);
  Rx<LatLng?> dropoffLatLng = Rx<LatLng?>(null);

  // Map controller
  GoogleMapController? mapController;

  // Markers - using RxInt to trigger rebuilds
  final RxInt markersVersion = 0.obs;
  Set<Marker> markers = {};

  // Polylines for route
  Set<Polyline> polylines = {};

  // Categories
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoadingCategories = false.obs;
  final RxInt selectedCategoryId = 0.obs;

  // Delivery creation
  final RxBool isCreatingDelivery = false.obs;

  final RxList<String> recentLocations = <String>[
    "236 Cole Ave, Lagos, Nigeria",
    "23 Avery Str, Lagos, Nigeria",
    "2 Ikorodu Str, Lagos, Nigeria",
  ].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  @override
  void onClose() {
    pickupController.dispose();
    dropoffController.dispose();
    mapController?.dispose();
    super.onClose();
  }

  void setPickupLocation(String location, {double? lat, double? lng}) {
    selectedPickupLocation.value = location;
    pickupController.text = location;

    if (lat != null && lng != null) {
      pickupLatLng.value = LatLng(lat, lng);
      _updateMarkersAndPolylines();
      _animateToShowBothMarkers();
    }
  }

  void setDropoffLocation(String location, {double? lat, double? lng}) {
    selectedDropoffLocation.value = location;
    dropoffController.text = location;

    if (lat != null && lng != null) {
      dropoffLatLng.value = LatLng(lat, lng);
      _updateMarkersAndPolylines();
      _animateToShowBothMarkers();
    }
  }

  void selectRecentLocation(String location, bool isPickup) {
    if (isPickup) {
      setPickupLocation(location);
    } else {
      setDropoffLocation(location);
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _updateMarkersAndPolylines() {
    markers.clear();
    polylines.clear();

    if (pickupLatLng.value != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: pickupLatLng.value!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(
            title: 'Pickup Location',
            snippet: selectedPickupLocation.value,
          ),
        ),
      );
    }

    if (dropoffLatLng.value != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('dropoff'),
          position: dropoffLatLng.value!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Drop-off Location',
            snippet: selectedDropoffLocation.value,
          ),
        ),
      );
    }

    // Draw line between pickup and dropoff
    if (pickupLatLng.value != null && dropoffLatLng.value != null) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: [pickupLatLng.value!, dropoffLatLng.value!],
          color: Colors.blue,
          width: 5,
          patterns: [PatternItem.dash(30), PatternItem.gap(20)],
        ),
      );
    }

    // Trigger rebuild by incrementing version
    markersVersion.value++;
  }

  void _animateToShowBothMarkers() {
    if (mapController == null) return;

    if (pickupLatLng.value != null && dropoffLatLng.value != null) {
      // Calculate bounds to show both markers
      double minLat =
          pickupLatLng.value!.latitude < dropoffLatLng.value!.latitude
          ? pickupLatLng.value!.latitude
          : dropoffLatLng.value!.latitude;
      double maxLat =
          pickupLatLng.value!.latitude > dropoffLatLng.value!.latitude
          ? pickupLatLng.value!.latitude
          : dropoffLatLng.value!.latitude;
      double minLng =
          pickupLatLng.value!.longitude < dropoffLatLng.value!.longitude
          ? pickupLatLng.value!.longitude
          : dropoffLatLng.value!.longitude;
      double maxLng =
          pickupLatLng.value!.longitude > dropoffLatLng.value!.longitude
          ? pickupLatLng.value!.longitude
          : dropoffLatLng.value!.longitude;

      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    } else if (pickupLatLng.value != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(pickupLatLng.value!, 14),
      );
    } else if (dropoffLatLng.value != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(dropoffLatLng.value!, 14),
      );
    }
  }

  Future<void> fetchCategories() async {
    isLoadingCategories.value = true;
    try {
      var response = await http.get(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.fetchCategories),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${StorageHelper.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['success'] == true) {
          categories.value = (data['data'] as List)
              .map((json) => CategoryModel.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  void selectCategory(int categoryId) {
    selectedCategoryId.value = categoryId;
  }

  Future<bool> createDelivery() async {
    if (pickupLatLng.value == null || dropoffLatLng.value == null) {
      debugPrint('Missing pickup or dropoff location');
      return false;
    }

    isCreatingDelivery.value = true;
    try {
      // Get user profile data
      final userId = StorageHelper.getUserId();
      final token = StorageHelper.getToken();

      // Prepare request body
      final requestBody = {
        "name": StorageHelper.box.read('userName') ?? "User",
        "email": StorageHelper.box.read('userEmail') ?? "",
        "phone": StorageHelper.box.read('userPhone') ?? "",
        "latitude": pickupLatLng.value!.latitude,
        "longitude": pickupLatLng.value!.longitude,
        "address": selectedPickupLocation.value,
        "originLat": pickupLatLng.value!.latitude,
        "originLng": pickupLatLng.value!.longitude,
        "destLat": dropoffLatLng.value!.latitude,
        "destLng": dropoffLatLng.value!.longitude,
        "price": 1000, // Placeholder price
        "senderId": userId,
      };

      debugPrint('Creating delivery with data:');
      debugPrint(jsonEncode(requestBody));

      var response = await http.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.createDelivery),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('Create delivery response status: ${response.statusCode}');
      debugPrint('Create delivery response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse response to get delivery ID
        try {
          final jsonResponse = jsonDecode(response.body);
          if (jsonResponse['data'] != null &&
              jsonResponse['data']['id'] != null) {
            final deliveryId = jsonResponse['data']['id'].toString();
            StorageHelper.box.write('currentDeliveryId', deliveryId);
            debugPrint('Delivery created successfully! ID: $deliveryId');
          }
        } catch (e) {
          debugPrint('Error parsing delivery ID: $e');
        }
        return true;
      } else {
        debugPrint('Failed to create delivery: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error creating delivery: $e');
      return false;
    } finally {
      isCreatingDelivery.value = false;
    }
  }
}
