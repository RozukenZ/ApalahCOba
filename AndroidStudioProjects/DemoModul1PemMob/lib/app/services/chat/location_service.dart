import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';


class LocationService {
  /// Memastikan layanan lokasi diaktifkan
  Future<bool> _checkLocationServiceEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Error", "Location services are disabled.");
      return false;
    }
    return true;
  }

  /// Memeriksa dan meminta izin lokasi
  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar("Error", "Location permissions are denied.");
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar("Error",
          "Location permissions are permanently denied. Please enable permissions in settings.");
      return false;
    }
    return true;
  }

  /// Mendapatkan lokasi saat ini
  Future<String?> getCurrentLocation() async {
    if (!await _checkLocationServiceEnabled() ||
        !await _requestLocationPermission()) {
      return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Format hasil ke dalam link Google Maps
      String locationUrl =
          "https://www.google.com/maps?q=${position.latitude},${position.longitude}";
      print("Generated Location URL: $locationUrl");
      return locationUrl;
    } catch (e) {
      Get.snackbar("Error", "Failed to get location: $e");
      return null;
    }
  }
}
