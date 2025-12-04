import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  final RxList<String> recentLocations = <String>[
    "236 Cole Ave, Lagos, Nigeria",
    "23 Avery Str, Lagos, Nigeria",
    "2 Ikorodu Str, Lagos, Nigeria",
  ].obs;

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
}
