import 'package:get/get.dart';
import '../services/chat/chat_service.dart';
import '../services/chat/location_service.dart';

class LocationController extends GetxController {
  final LocationService locationService = LocationService();
  final ChatService chatService = ChatService();

  /// Fungsi untuk berbagi lokasi
  Future<void> shareLocation(String receiverId) async {
    String? locationMessage = await locationService.getCurrentLocation();

    if (locationMessage != null) {
      print("Location fetched: $locationMessage");

      // Kirim lokasi ke pengguna melalui ChatService
      await chatService.sendMessage(receiverId, locationMessage);

      Get.snackbar("Success", "Location shared successfully!");
    } else {
      print("Failed to fetch location");
      Get.snackbar("Error", "Unable to fetch location!");
    }
  }
}
