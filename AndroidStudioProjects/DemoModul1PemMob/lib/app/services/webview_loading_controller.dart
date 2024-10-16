import 'package:get/get.dart';

class WebViewLoadingController extends GetxController {
  var isLoading = true.obs;

  void setLoading(bool value) {
    isLoading.value = value;
  }
}
