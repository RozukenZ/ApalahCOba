import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../articles/article.dart';

class HttpController extends GetxController {
  final http.Client _httpClient = http.Client();
  final apiUrl = 'https://my-json-server.typicode.com/Fallid/codelab-api/db';

  var isLoading = false.obs;
  var articles = Rx<Articles?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    try {
      isLoading.value = true;
      final response = await _httpClient.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        articles.value = Articles.fromJson(jsonData);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch articles: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
