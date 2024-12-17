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
      Get.snackbar(
          "Error", "Location permissions are permanently denied. Please enable permissions in settings.");
      return false;
    }
    return true;
  }


  Future<String?> getCurrentLocation() async {
    // Pastikan layanan dan izin lokasi tersedia
    if (!await _checkLocationServiceEnabled() ||
        !await _requestLocationPermission()) {
      return null;
    }

    try {
      // Ambil lokasi dengan akurasi tinggi
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Format hasil ke dalam link Google Maps
      return "https://www.google.com/maps?q=${position.latitude},${position.longitude}";
    } catch (e) {
      // Tangani error ketika pengambilan lokasi gagal
      Get.snackbar("Error", "Failed to get location: $e");
      return null;
    }
  }
}