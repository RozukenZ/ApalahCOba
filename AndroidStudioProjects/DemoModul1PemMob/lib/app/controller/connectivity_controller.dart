import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_storage/get_storage.dart';
import '../services/chat/chat_service.dart';

class ConnectivityController extends GetxController {
  final Rx<ConnectivityResult> _connectionStatus = ConnectivityResult.none.obs;
  RxBool isConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    initConnectivity();
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results.first);
    });
  }

  Future<void> initConnectivity() async {
    try {
      List<ConnectivityResult> result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result.first);
    } catch (e) {
      print('Connectivity check error: $e');
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    _connectionStatus.value = result;
    isConnected.value = result != ConnectivityResult.none;

    if (isConnected.value) {
      Get.snackbar(
        'Internet Connection',
        'Back Online',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _syncOfflineData();
    } else {
      Get.snackbar(
        'No Internet',
        'Connection Lost',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _syncOfflineData() async {
    final offlineMessages = GetStorage().read('offline_messages') ?? [];
    if (offlineMessages.isNotEmpty) {
      final chatService = ChatService();
      for (var messageData in offlineMessages) {
        await chatService.sendMessage(
            messageData['receiverId'],
            messageData['message']
        );
      }
      // Clear offline messages after sync
      GetStorage().remove('offline_messages');
    }
  }
}