import 'package:get/get.dart';
import '../services/chat/chat_service.dart';
import '../services/chat/location_service.dart';

class LocationController extends GetxController {
  final LocationService locationService = LocationService();
  final ChatService chatService = ChatService();

  /// Fungsi untuk berbagi lokasi
  Future<void> shareLocation(String receiverUserID) async {
    print("shareLocation called for receiverUserID: $receiverUserID");

    // Ambil lokasi saat ini
    String? locationMessage = await locationService.getCurrentLocation();

    // Jika lokasi berhasil diambil, kirimkan lokasi
    if (locationMessage != null) {
      print("Location fetched: $locationMessage");

      // Kirim pesan melalui ChatService
      await chatService.sendMessage(receiverUserID, locationMessage);

      // Tampilkan notifikasi sukses
      Get.snackbar("Success", "Location shared successfully!");
    } else {
      print("Failed to fetch location");
      Get.snackbar("Error", "Unable to fetch location!");
    }
  }
}
